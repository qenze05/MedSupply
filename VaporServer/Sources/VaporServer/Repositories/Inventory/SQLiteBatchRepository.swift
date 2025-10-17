//
//  SQLiteBatchRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct SQLiteBatchRepository: BatchRepository {
  func create(_ batch: Batch, on db: any Database) async throws -> Batch {
    if let _ = try await Batch.query(on: db)
      .filter(\.$product.$id == batch.$product.id)
      .filter(\.$batchNumber == batch.batchNumber)
      .first() {
      throw RepositoryError.duplicate
    }
    try await batch.create(on: db)
    return batch
  }

  func find(id: UUID, on db: any Database) async throws -> Batch? {
    try await Batch.find(id, on: db)
  }

  func findByProductAndNumber(productID: UUID, batchNumber: String, on db: any Database) async throws -> Batch? {
    try await Batch.query(on: db)
      .filter(\.$product.$id == productID)
      .filter(\.$batchNumber == batchNumber)
      .first()
  }

  func list(productID: UUID, limit: Int, offset: Int, on db: any Database) async throws -> [Batch] {
    try await Batch.query(on: db)
      .filter(\.$product.$id == productID)
      .range(offset..<(offset+limit))
      .all()
  }

  func update(_ batch: Batch, on db: any Database) async throws -> Batch {
    try await batch.update(on: db)
    return batch
  }

  func delete(id: UUID, on db: any Database) async throws {
    guard let found = try await Batch.find(id, on: db) else { throw RepositoryError.notFound }
    try await found.delete(on: db)
  }
}
