//
//  CreateStockMovement.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct CreateStockMovement: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(StockMovement.schema)
      .id()
      .field(StockMovement.FieldKeys.productID, .uuid, .required, .references(Product.schema, .id, onDelete: .cascade))
      .field(StockMovement.FieldKeys.fromLocationID, .uuid, .references(Location.schema, .id, onDelete: .setNull))
      .field(StockMovement.FieldKeys.toLocationID, .uuid, .references(Location.schema, .id, onDelete: .setNull))
      .field(StockMovement.FieldKeys.batchID, .uuid, .references(Batch.schema, .id, onDelete: .setNull))
      .field(StockMovement.FieldKeys.quantity, .int, .required)
      .field(StockMovement.FieldKeys.kind, .string, .required)
      .field(StockMovement.FieldKeys.reason, .string)
      .field(StockMovement.FieldKeys.reference, .string)
      .field(StockMovement.FieldKeys.performedByUserID, .uuid)
      .field(StockMovement.FieldKeys.createdAt, .datetime)
      .create()
  }
  
  func revert(on db: any Database) async throws {
    try await db.schema(StockMovement.schema).delete()
  }
}
