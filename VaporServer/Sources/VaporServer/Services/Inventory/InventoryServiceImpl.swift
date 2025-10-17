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
  init(repos: Application.Repositories) { self.repos = repos }

  // MARK: - Helpers

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

  // MARK: - Query

  func getLevel(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel? {
    try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: batchID, on: db)
  }

  func listLevels(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockLevel] {
    try await repos.stockLevel.list(productID: productID, locationID: locationID, limit: limit, offset: offset, on: db)
  }

  func listMovements(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockMovement] {
    try await repos.movement.list(productID: productID, locationID: locationID, limit: limit, offset: offset, on: db)
  }

  // MARK: - Core flows

  func inbound(productID: UUID, to locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)

    return try await db.transaction { tx in
      let level = try await repos.stockLevel.changeOnHand(productID: productID, locationID: locationID, batchID: batchID, delta: qty, on: tx)
      try await record(kind: .inbound, productID: productID, from: nil, to: locationID, batchID: batchID,
                       qty: qty, reason: reason, reference: reference, performedBy: performedBy, on: tx)
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
      // 1) Знайти рівень
      guard let row = try await repos.stockLevel.find(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        on: tx
      ) else {
        throw InventoryError.notEnoughStock
      }

      // 2) Перевірити, що фізично вистачає на складі
      guard row.onHand >= qty else {
        throw InventoryError.notEnoughStock
      }

      // 3) Спожити резерв у першу чергу
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

      // 4) onHand зменшуємо на ПОВНИЙ qty (а не лише на "вільну" частину)
      _ = try await repos.stockLevel.changeOnHand(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        delta: -qty,
        on: tx
      )

      // 5) Оновлене значення рівня
      let updated = try await repos.stockLevel.getOrCreate(
        productID: productID,
        locationID: locationID,
        batchID: batchID,
        on: tx
      )

      // 6) Журнал рухів
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

      return updated
    }
  }


  func transfer(productID: UUID, from fromLocationID: UUID, to toLocationID: UUID, batchID: UUID?, qty: Int,
                reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> (from: StockLevel, to: StockLevel) {
    try validateQty(qty)
    if fromLocationID == toLocationID { throw InventoryError.unknown("Transfer to the same location is not allowed.") }
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)

    return try await db.transaction { tx in
      // Check available at source
      guard let src = try await repos.stockLevel.find(productID: productID, locationID: fromLocationID, batchID: batchID, on: tx) else {
        throw InventoryError.notEnoughStock
      }
      let available = src.onHand - src.reserved
      guard available >= qty else { throw InventoryError.notEnoughStock }

      // Move
      let fromLevel = try await repos.stockLevel.changeOnHand(productID: productID, locationID: fromLocationID, batchID: batchID, delta: -qty, on: tx)
      let toLevel   = try await repos.stockLevel.changeOnHand(productID: productID, locationID: toLocationID,   batchID: batchID, delta: +qty, on: tx)

      try await record(kind: .transfer, productID: productID, from: fromLocationID, to: toLocationID, batchID: batchID,
                       qty: qty, reason: reason, reference: reference, performedBy: performedBy, on: tx)
      return (fromLevel, toLevel)
    }
  }

  func reserve(productID: UUID, at locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel {
    try validateQty(qty)
    try await ensureBatchBelongs(productID: productID, batchID: batchID, on: db)

    return try await db.transaction { tx in
      // Check available
      guard let row = try await repos.stockLevel.find(productID: productID, locationID: locationID, batchID: batchID, on: tx) else {
        throw InventoryError.notEnoughStock
      }
      let available = row.onHand - row.reserved
      guard available >= qty else { throw InventoryError.notEnoughStock }

      let updated = try await repos.stockLevel.changeReserved(productID: productID, locationID: locationID, batchID: batchID, delta: +qty, on: tx)
      try await record(kind: .adjustment, productID: productID, from: nil, to: nil, batchID: batchID,
                       qty: qty, reason: reason ?? "reserve", reference: reference, performedBy: performedBy, on: tx)
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
        // Record as inventory operation; direction by sign
        if delta > 0 {
          try await record(kind: .inventory, productID: productID, from: nil, to: locationID, batchID: batchID,
                           qty: delta, reason: reason ?? "inventory +", reference: reference, performedBy: performedBy, on: tx)
        } else {
          try await record(kind: .inventory, productID: productID, from: locationID, to: nil, batchID: batchID,
                           qty: -delta, reason: reason ?? "inventory -", reference: reference, performedBy: performedBy, on: tx)
        }
      }
      return updated
    }
  }
}
