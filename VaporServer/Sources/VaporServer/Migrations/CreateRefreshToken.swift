//
//  CreateRefreshToken.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Fluent

struct CreateRefreshToken: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(RefreshToken.schema)
      .id()
      .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
      .field("token_hash", .string, .required)
      .field("expires_at", .datetime, .required)
      .field("revoked_at", .datetime)
      .field("created_at", .datetime)
      .unique(on: "token_hash")
      .create()
  }
  
  func revert(on db: any Database) async throws {
    try await db.schema(RefreshToken.schema).delete()
  }
}
