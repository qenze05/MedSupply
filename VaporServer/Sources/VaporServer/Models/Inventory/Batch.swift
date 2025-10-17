//
//  Batch.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import Fluent

final class Batch: Model, Content {
    static let schema = "batches"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.productID)
    var product: Product

    @Field(key: FieldKeys.batchNumber)
    var batchNumber: String

    @OptionalField(key: FieldKeys.expiresAt)
    var expiresAt: Date?

    @Children(for: \.$batch)
    var stockLevels: [StockLevel]

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, productID: UUID, batchNumber: String, expiresAt: Date?) {
        self.id = id
        self.$product.id = productID
        self.batchNumber = batchNumber
        self.expiresAt = expiresAt
    }
}

extension Batch {
    enum FieldKeys {
        static let productID = FieldKey("product_id")
        static let batchNumber = FieldKey("batch_number")
        static let expiresAt = FieldKey("expires_at")
        static let createdAt = FieldKey("created_at")
        static let updatedAt = FieldKey("updated_at")
    }
}

extension Batch: @unchecked Sendable {}
