//
//  CreateBatch.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct CreateBatch: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(Batch.schema)
            .id()
            .field(Batch.FieldKeys.productID, .uuid, .required, .references(Product.schema, .id, onDelete: .cascade))
            .field(Batch.FieldKeys.batchNumber, .string, .required)
            .field(Batch.FieldKeys.expiresAt, .datetime)
            .field(Batch.FieldKeys.createdAt, .datetime)
            .field(Batch.FieldKeys.updatedAt, .datetime)
            .unique(on: Batch.FieldKeys.productID, Batch.FieldKeys.batchNumber)
            .create()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(Batch.schema).delete()
    }
}
