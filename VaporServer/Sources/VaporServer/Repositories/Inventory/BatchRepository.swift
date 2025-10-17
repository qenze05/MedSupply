//
//  BatchRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol BatchRepository: Sendable {
  func create(_ batch: Batch, on db: any Database) async throws -> Batch
  func find(id: UUID, on db: any Database) async throws -> Batch?
  func findByProductAndNumber(productID: UUID, batchNumber: String, on db: any Database) async throws -> Batch?
  func list(productID: UUID, limit: Int, offset: Int, on db: any Database) async throws -> [Batch]
  func update(_ batch: Batch, on db: any Database) async throws -> Batch
  func delete(id: UUID, on db: any Database) async throws
}
