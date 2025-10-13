//
//  User.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

final class User: Model, Content {
  static let schema = "users"
  
  @ID(key: .id) var id: UUID?
  @Field(key: "email") var email: String
  @Field(key: "password_hash") var passwordHash: String
  @OptionalField(key: "full_name") var fullName: String?
  @Field(key: "role") var role: String
  @Timestamp(key: "created_at", on: .create) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
  
  init() {}
  init(id: UUID? = nil, email: String, passwordHash: String, fullName: String?, role: String) {
    self.id = id
    self.email = email
    self.passwordHash = passwordHash
    self.fullName = fullName
    self.role = role
  }
}

extension User: @unchecked Sendable {}
