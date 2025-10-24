//
//  CreatePayment.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Fluent

struct CreatePayment: AsyncMigration {
  func prepare(on db: any Database) async throws {
    try await db.schema(Payment.schema)
      .id()
      .field("request_id", .uuid, .required)
      .field("amount", .int, .required)
      .field("currency", .string, .required)
      .field("status", .string, .required)
      .field("provider_id", .string)
      .field("failure_reason", .string)
      .field("created_at", .datetime)
      .field("updated_at", .datetime)
      .create()
  }
  func revert(on db: any Database) async throws {
    try await db.schema(Payment.schema).delete()
  }
}
