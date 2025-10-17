//
//  SQLiteStockMovementRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct SQLiteStockMovementRepository: StockMovementRepository {
  func record(_ movement: StockMovement, on db: any Database) async throws -> StockMovement {
    try await movement.create(on: db)
    return movement
  }

  func list(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockMovement] {
    var q = StockMovement.query(on: db).sort(\.$createdAt, .descending)
    if let productID { q = q.filter(\.$product.$id == productID) }
    if let locationID {
      q = q.group(.or) { g in
        g.filter(\.$fromLocation.$id == locationID)
        g.filter(\.$toLocation.$id == locationID)
      }
    }
    return try await q.range(offset..<(offset+limit)).all()
  }
}
