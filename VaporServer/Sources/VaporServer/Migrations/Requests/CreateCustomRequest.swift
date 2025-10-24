//
//  File.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Fluent

struct CreateCustomerRequest: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(CustomerRequest.schema)
      .id()
      .field("customer_id", .uuid, .required,
             .references("users", .id, onDelete: .cascade))
      .field("product_id", .uuid, .required,
             .references("products", .id, onDelete: .restrict))
      .field("quantity", .int, .required)
      .field("comment", .string)
      .field("status", .string, .required)
      .field("created_at", .datetime)
      .field("updated_at", .datetime)
      .create()
  }

  func revert(on db: any Database) async throws {
    try await db.schema(CustomerRequest.schema).delete()
  }
}
