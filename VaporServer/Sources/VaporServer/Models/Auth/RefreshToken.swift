//
//  RefreshToken.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

final class RefreshToken: Model, Content {
  static let schema = "refresh_tokens"
  
  @ID(key: .id) var id: UUID?
  @Parent(key: "user_id") var user: User
  @Field(key: "token_hash") var tokenHash: String
  @Field(key: "expires_at") var expiresAt: Date
  @OptionalField(key: "revoked_at") var revokedAt: Date?
  @Timestamp(key: "created_at", on: .create) var createdAt: Date?
  
  init() {}
  init(id: UUID? = nil, userID: UUID, tokenHash: String, expiresAt: Date, revokedAt: Date? = nil) {
    self.id = id
    self.$user.id = userID
    self.tokenHash = tokenHash
    self.expiresAt = expiresAt
    self.revokedAt = revokedAt
  }
}

extension RefreshToken: @unchecked Sendable {}
