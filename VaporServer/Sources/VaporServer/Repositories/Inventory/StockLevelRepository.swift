//
//  StockLevelRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol StockLevelRepository: Sendable {
  /// Get (or create zero row) for (product, location, batch)
  func getOrCreate(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel

  /// Set absolute onHand (inventory correction)
  func setOnHand(productID: UUID, locationID: UUID, batchID: UUID?, to newValue: Int, on db: any Database) async throws -> StockLevel

  /// Reserve/unreserve does not change onHand
  func changeReserved(productID: UUID, locationID: UUID, batchID: UUID?, delta: Int, on db: any Database) async throws -> StockLevel

  /// Add/subtract onHand (inbound/outbound/transfer leg)
  func changeOnHand(productID: UUID, locationID: UUID, batchID: UUID?, delta: Int, on db: any Database) async throws -> StockLevel

  /// Query helpers
  func find(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel?
  func list(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockLevel]
}
