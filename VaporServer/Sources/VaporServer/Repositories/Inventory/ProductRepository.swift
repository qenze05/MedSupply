//
//  ProductRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol ProductRepository: Sendable {
  func create(_ product: Product, on db: any Database) async throws -> Product
  func find(id: UUID, on db: any Database) async throws -> Product?
  func findBySKU(_ sku: String, on db: any Database) async throws -> Product?
  func list(limit: Int, offset: Int, on db: any Database) async throws -> [Product]
  func update(_ product: Product, on db: any Database) async throws -> Product
  func delete(id: UUID, on db: any Database) async throws
}
