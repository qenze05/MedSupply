//
//  SQLiteProductRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct SQLiteProductRepository: ProductRepository {
  func create(_ product: Product, on db: any Database) async throws -> Product {
    if let _ = try await Product.query(on: db).filter(\.$sku == product.sku).first() {
      throw RepositoryError.duplicate
    }
    try await product.create(on: db)
    return product
  }

  func find(id: UUID, on db: any Database) async throws -> Product? {
    try await Product.find(id, on: db)
  }

  func findBySKU(_ sku: String, on db: any Database) async throws -> Product? {
    try await Product.query(on: db).filter(\.$sku == sku).first()
  }

  func list(limit: Int, offset: Int, on db: any Database) async throws -> [Product] {
    try await Product.query(on: db).range(offset..<(offset+limit)).all()
  }

  func update(_ product: Product, on db: any Database) async throws -> Product {
    try await product.update(on: db)
    return product
  }

  func delete(id: UUID, on db: any Database) async throws {
    guard let found = try await Product.find(id, on: db) else { throw RepositoryError.notFound }
    try await found.delete(on: db)
  }
}
