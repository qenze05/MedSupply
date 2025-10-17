//
//  CreateProduct.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Fluent

struct CreateProduct: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(Product.schema)
      .id()
      .field(Product.FieldKeys.sku, .string, .required)
      .field(Product.FieldKeys.name, .string, .required)
      .field(Product.FieldKeys.desc, .string)
      .field(Product.FieldKeys.unit, .string, .required)
      .field(Product.FieldKeys.createdByUserID, .uuid)
      .field(Product.FieldKeys.createdAt, .datetime)
      .field(Product.FieldKeys.updatedAt, .datetime)
      .field(Product.FieldKeys.deletedAt, .datetime)
      .unique(on: Product.FieldKeys.sku)
      .create()
  }
  func revert(on db: any Database) async throws {
    try await db.schema(Product.schema).delete()
  }
}
