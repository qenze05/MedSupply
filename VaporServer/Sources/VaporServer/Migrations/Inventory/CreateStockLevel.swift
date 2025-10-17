//
//  CreateStockLevel.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct CreateStockLevel: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(StockLevel.schema)
            .id()
            .field(StockLevel.FieldKeys.productID, .uuid, .required, .references(Product.schema, .id, onDelete: .cascade))
            .field(StockLevel.FieldKeys.locationID, .uuid, .required, .references(Location.schema, .id, onDelete: .cascade))
            .field(StockLevel.FieldKeys.batchID, .uuid, .references(Batch.schema, .id, onDelete: .setNull))
            .field(StockLevel.FieldKeys.onHand, .int, .required, .sql(.default(0)))
            .field(StockLevel.FieldKeys.reserved, .int, .required, .sql(.default(0)))
            .field(StockLevel.FieldKeys.reorderLevel, .int)
            .field(StockLevel.FieldKeys.createdAt, .datetime)
            .field(StockLevel.FieldKeys.updatedAt, .datetime)
            // унікальна комбінація рівня запасів
            .unique(on: StockLevel.FieldKeys.productID, StockLevel.FieldKeys.locationID, StockLevel.FieldKeys.batchID)
            .create()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(StockLevel.schema).delete()
    }
}
