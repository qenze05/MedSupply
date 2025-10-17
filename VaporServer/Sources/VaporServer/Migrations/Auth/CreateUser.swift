//
//  CreateUser.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Fluent

struct CreateUser: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(User.schema)
      .id()
      .field("email", .string, .required)
      .field("password_hash", .string, .required)
      .field("full_name", .string)
      .field("role", .string, .required)
      .field("created_at", .datetime)
      .field("updated_at", .datetime)
      .unique(on: "email")
      .create()
  }
  
  func revert(on db: any Database) async throws {
    try await db.schema(User.schema).delete()
  }
}
