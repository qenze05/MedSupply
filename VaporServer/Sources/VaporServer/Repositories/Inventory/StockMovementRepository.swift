//
//  StockMovementRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol StockMovementRepository: Sendable {
  func record(_ movement: StockMovement, on db: any Database) async throws -> StockMovement
  func list(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockMovement]
}
