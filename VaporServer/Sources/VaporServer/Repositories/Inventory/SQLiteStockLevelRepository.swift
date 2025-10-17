//
//  SQLiteStockLevelRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct SQLiteStockLevelRepository: StockLevelRepository {

  func getOrCreate(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel {
    if let existing = try await find(productID: productID, locationID: locationID, batchID: batchID, on: db) {
      return existing
    }
    let item = StockLevel(productID: productID, locationID: locationID, batchID: batchID, onHand: 0, reserved: 0, reorderLevel: nil)
    try await item.create(on: db)
    return item
  }

  func setOnHand(productID: UUID, locationID: UUID, batchID: UUID?, to newValue: Int, on db: any Database) async throws -> StockLevel {
    try await db.transaction { tx in
      guard newValue >= 0 else { throw RepositoryError.invalidState("onHand cannot be negative") }
      let row = try await getOrCreate(productID: productID, locationID: locationID, batchID: batchID, on: tx)
      guard row.reserved <= newValue else {
        throw RepositoryError.invalidState("onHand < reserved")
      }
      row.onHand = newValue
      try await row.update(on: tx)
      return row
    }
  }

  func changeReserved(productID: UUID, locationID: UUID, batchID: UUID?, delta: Int, on db: any Database) async throws -> StockLevel {
    try await db.transaction { tx in
      let row = try await getOrCreate(productID: productID, locationID: locationID, batchID: batchID, on: tx)
      let newReserved = row.reserved + delta
      guard newReserved >= 0 else { throw RepositoryError.invalidState("reserved would be negative") }
      guard newReserved <= row.onHand else { throw RepositoryError.invalidState("reserved exceeds onHand") }
      row.reserved = newReserved
      try await row.update(on: tx)
      return row
    }
  }

  func changeOnHand(productID: UUID, locationID: UUID, batchID: UUID?, delta: Int, on db: any Database) async throws -> StockLevel {
    try await db.transaction { tx in
      let row = try await getOrCreate(productID: productID, locationID: locationID, batchID: batchID, on: tx)
      let newOnHand = row.onHand + delta
      guard newOnHand >= 0 else { throw RepositoryError.invalidState("onHand would be negative") }
      guard row.reserved <= newOnHand else { throw RepositoryError.invalidState("reserved would exceed onHand") }
      row.onHand = newOnHand
      try await row.update(on: tx)
      return row
    }
  }

  func find(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel? {
    try await StockLevel.query(on: db)
      .filter(\.$product.$id == productID)
      .filter(\.$location.$id == locationID)
      .group(.and) { q in
        if let batchID { q.filter(\.$batch.$id == batchID) }
        else { q.filter(\.$batch.$id == .null) }
      }
      .first()
  }

  func list(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockLevel] {
    var q = StockLevel.query(on: db)
    if let productID { q = q.filter(\.$product.$id == productID) }
    if let locationID { q = q.filter(\.$location.$id == locationID) }
    return try await q.range(offset..<(offset+limit)).all()
  }
}
