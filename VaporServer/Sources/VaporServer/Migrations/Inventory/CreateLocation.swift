//
//  CreateLocation.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct CreateLocation: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(Location.schema)
            .id()
            .field(Location.FieldKeys.code, .string, .required)
            .field(Location.FieldKeys.name, .string, .required)
            .field(Location.FieldKeys.address, .string)
            .field(Location.FieldKeys.isActive, .bool, .required, .sql(.default(true)))
            .field(Location.FieldKeys.createdAt, .datetime)
            .field(Location.FieldKeys.updatedAt, .datetime)
            .field(Location.FieldKeys.deletedAt, .datetime)
            .unique(on: Location.FieldKeys.code)
            .create()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(Location.schema).delete()
    }
}
