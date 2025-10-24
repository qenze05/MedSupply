//
//  CreateNotifications.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 24.10.2025.
//


import Fluent

struct CreateNotifications: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(NotificationRecord.schema)
      .id()
      .field("recipient_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .field("recipient_email", .string, .required)
      .field("channel", .string, .required)
      .field("status", .string, .required)
      .field("subject", .string, .required)
      .field("body", .string, .required)
      .field("error", .string)
      .field("created_at", .datetime)
      .field("sent_at", .datetime)
      .create()
  }
  func revert(on db: any Database) async throws {
    try await db.schema(NotificationRecord.schema).delete()
  }
}
