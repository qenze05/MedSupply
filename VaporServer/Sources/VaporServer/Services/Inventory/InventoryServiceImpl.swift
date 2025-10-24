//
//  InventoryServiceImpl.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import Fluent

struct InventoryServiceImpl: InventoryService, @unchecked Sendable {
  
  private let repos: Application.Repositories
  private let notifs: any NotificationService
  
  init(repos: Application.Repositories, notifs: any NotificationService) {
    self.repos = repos
    self.notifs = notifs
  }
  
  private func validateQty(_ qty: Int) throws {
    if qty <= 0 { throw InventoryError.invalidQuantity }
  }
  
  private func ensureBatchBelongs(productID: UUID, batchID: UUID?, on db: any Database) async throws {
    guard let batchID else { return }
    guard let batch = try await repos.batch.find(id: batchID, on: db) else {
      throw RepositoryError.notFound
    }
    if batch.$product.id != productID {
      throw InventoryError.batchMismatch
    }
  }
  
  private func record(kind: StockMovement.Kind, productID: UUID, from fromLocationID: UUID?, to toLocationID: UUID?, batchID: UUID?,
                      qty: Int, reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws {
    let move = StockMovement(
      productID: productID,
      fromLocationID: fromLocationID,
      toLocationID: toLocationID,
      batchID: batchID,
      quantity: qty,
      kind: kind,
      reason: reason,
      reference: reference,
      performedByUserID: performedBy
    )
    _ = try await repos.movement.record(move, on: db)
  }
  
  
  func getLevel(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel? {
    try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: batchID, on: db)
  }
  
  func listLevels(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockLevel] {
    try await repos.stockLevel.list(productID: productID, locationID: locationID, limit: limit, offset: offset, on: db)
  }
  
  func listMovements(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockMovement] {
    try await repos.movement.list(productID: productID, locationID: locationID, limit: limit, offset: offset, on: db)
  }
  
  
  func inbound(productID: UUID, to locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      let level = try await repos.stockLevel.changeOnHand(productID: productID, locationID: locationID, batchID: batchID, delta: qty, on: tx)
      try await record(kind: .inbound, productID: productID, from: nil, to: locationID, batchID: batchID,
                       qty: qty, reason: reason, reference: reference, performedBy: performedBy, on: tx)
      try? await checkReorderAndNotify(productID: productID, locationID: locationID, on: db)
      return level
    }
  }
  
  func outbound(productID: UUID,
                from locationID: UUID,
                batchID: UUID?,
                qty: Int,
                reason: String?,
                reference: String?,
                performedBy: UUID?,
                on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      guard let row = try await repos.stockLevel.find(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        on: tx
      ) else {
        throw InventoryError.notEnoughStock
      }
      
      guard row.onHand >= qty else {
        throw InventoryError.notEnoughStock
      }
      
      let reservedConsume = min(row.reserved, qty)
      if reservedConsume > 0 {
        _ = try await repos.stockLevel.changeReserved(
          productID: productID,
          locationID: locationID,
          batchID: batchID,
          delta: -reservedConsume,
          on: tx
        )
      }
      
      _ = try await repos.stockLevel.changeOnHand(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        delta: -qty,
        on: tx
      )
      
      let updated = try await repos.stockLevel.getOrCreate(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        on: tx
      )
      
      try await record(
        kind: .outbound,
        productID: productID,
        from: locationID,
        to: nil,
        batchID: batchID,
        qty: qty,
        reason: reason,
        reference: reference,
        performedBy: performedBy,
        on: tx
      )
      
      try? await checkReorderAndNotify(productID: productID, locationID: locationID, on: db)
      
      return updated
    }
  }
  
  
  func transfer(productID: UUID, from fromLocationID: UUID, to toLocationID: UUID, batchID: UUID?, qty: Int,
                reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> (from: StockLevel, to: StockLevel) {
    try validateQty(qty)
    if fromLocationID == toLocationID { throw InventoryError.unknown("Transfer to the same location is not allowed.") }
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      guard let src = try await repos.stockLevel.find(productID: productID, locationID: fromLocationID, batchID: batchID, on: tx) else {
        throw InventoryError.notEnoughStock
      }
      let available = src.onHand - src.reserved
      guard available >= qty else { throw InventoryError.notEnoughStock }
      
      let fromLevel = try await repos.stockLevel.changeOnHand(productID: productID, locationID: fromLocationID, batchID: batchID, delta: -qty, on: tx)
      let toLevel   = try await repos.stockLevel.changeOnHand(productID: productID, locationID: toLocationID,   batchID: batchID, delta: +qty, on: tx)
      
      try await record(kind: .transfer, productID: productID, from: fromLocationID, to: toLocationID, batchID: batchID,
                       qty: qty, reason: reason, reference: reference, performedBy: performedBy, on: tx)
      
      try? await checkReorderAndNotify(productID: productID, locationID: fromLocationID, on: db)
      try? await checkReorderAndNotify(productID: productID, locationID: toLocationID,   on: db)

      return (fromLevel, toLevel)
    }
  }
  
  func reserve(productID: UUID, at locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      guard let row = try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: batchID, on: tx) else {
        throw InventoryError.notEnoughStock
      }
      let available = row.onHand - row.reserved
      guard available >= qty else { throw InventoryError.notEnoughStock }
      
      let updated = try await repos.stockLevel.changeReserved(productID: productID, locationID: locationID, batchID: batchID, delta: +qty, on: tx)
      try await record(kind: .adjustment, productID: productID, from: nil, to: nil, batchID: batchID,
                       qty: qty, reason: reason ?? "reserve", reference: reference, performedBy: performedBy, on: tx)
      
      try? await checkReorderAndNotify(productID: productID, locationID: locationID, on: db)
      
      return updated
    }
  }
  
  func unreserve(productID: UUID, at locationID: UUID, batchID: UUID?, qty: Int,
                 reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      guard let row = try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: batchID, on: tx) else {
        throw InventoryError.notEnoughStock
      }
      guard row.reserved >= qty else { throw InventoryError.notEnoughStock }
      
      let updated = try await repos.stockLevel.changeReserved(productID: productID, locationID: locationID, batchID: batchID, delta: -qty, on: tx)
      try await record(kind: .adjustment, productID: productID, from: nil, to: nil, batchID: batchID,
                       qty: qty, reason: reason ?? "unreserve", reference: reference, performedBy: performedBy, on: tx)
      
      try? await checkReorderAndNotify(productID: productID, locationID: locationID, on: db)

      return updated
    }
  }
  
  func setOnHand(productID: UUID, at locationID: UUID, batchID: UUID?, to newValue: Int,
                 reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    if newValue < 0 { throw InventoryError.invalidQuantity }
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)
    
    return try await db.transaction { tx in
      let current = try await repos.stockLevel.getOrCreate(productID: productID, locationID: locationID, batchID: batchID, on: tx)
      let delta = newValue - current.onHand
      let updated = try await repos.stockLevel.setOnHand(productID: productID, locationID: locationID, batchID: batchID, to: newValue, on: tx)
      
      if delta != 0 {
        if delta > 0 {
          try await record(kind: .inventory, productID: productID, from: nil, to: locationID, batchID: batchID,
                           qty: delta, reason: reason ?? "inventory +", reference: reference, performedBy: performedBy, on: tx)
        } else {
          try await record(kind: .inventory, productID: productID, from: locationID, to: nil, batchID: batchID,
                           qty: -delta, reason: reason ?? "inventory -", reference: reference, performedBy: performedBy, on: tx)
        }
      }
      
      try? await checkReorderAndNotify(productID: productID, locationID: locationID, on: db)
      
      return updated
    }
  }
}

// MARK: - Notifications
extension InventoryServiceImpl {
  private func checkReorderAndNotify(productID: UUID, locationID: UUID, on db: any Database) async throws {
      guard let level = try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: nil, on: db),
            let product = try await repos.product.find(id: productID, on: db),
            let threshold = level.reorderLevel
      else { return }

      let available = level.onHand - level.reserved
      guard available <= threshold else { return }

      if let ownerID = product.createdByUserID,
         let owner = try await User.find(ownerID, on: db) {
        let html = """
          <h3>Низький залишок</h3>
          <p>Товар: \(product.name)</p>
          <p>Локація: \(locationID.uuidString)</p>
          <p>Доступно: \(available)</p>
          <p>Поріг reorderLevel: \(threshold)</p>
        """
        try await notifs.notifyEmail(to: owner, subject: "Низький залишок: \(product.name)", html: html, plain: nil, on: db)
      }
    }
}
