//
//  InventoryService.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol InventoryService: Sendable {
  func getLevel(productID: UUID, locationID: UUID, batchID: UUID?, on db: any Database) async throws -> StockLevel?
  func listLevels(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockLevel]
  
  @discardableResult
  func inbound(productID: UUID, to locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel
  
  @discardableResult
  func outbound(productID: UUID, from locationID: UUID, batchID: UUID?, qty: Int,
                reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel
  
  @discardableResult
  func transfer(productID: UUID, from fromLocationID: UUID, to toLocationID: UUID, batchID: UUID?, qty: Int,
                reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> (from: StockLevel, to: StockLevel)
  
  @discardableResult
  func reserve(productID: UUID, at locationID: UUID, batchID: UUID?, qty: Int,
               reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel
  
  @discardableResult
  func unreserve(productID: UUID, at locationID: UUID, batchID: UUID?, qty: Int,
                 reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel
  
  @discardableResult
  func setOnHand(productID: UUID, at locationID: UUID, batchID: UUID?, to newValue: Int,
                 reason: String?, reference: String?, performedBy: UUID?, on db: any Database) async throws -> StockLevel
  
  func listMovements(productID: UUID?, locationID: UUID?, limit: Int, offset: Int, on db: any Database) async throws -> [StockMovement]
}
