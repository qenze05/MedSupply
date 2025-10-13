//
//  FluentUserRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

public struct FluentUserRepository: UserRepository, Sendable {
  public init() {}
  
  public func findByEmail(_ email: String, on req: Request) async throws -> UserRecord? {
    if let m = try await User.query(on: req.db)
      .filter(\.$email == email)
      .first()
    {
      return UserRecord(m)
    }
    return nil
  }
  
  public func findByID(_ id: UUID, on req: Request) async throws -> UserRecord? {
    if let m = try await User.find(id, on: req.db) {
      return UserRecord(m)
    }
    return nil
  }
  
  public func create(email: String, passwordHash: String, fullName: String?, role: String, on req: Request) async throws -> UserRecord {
    let user = User(email: email, passwordHash: passwordHash, fullName: fullName, role: role)
    try await user.save(on: req.db)
    guard let id = user.id else { throw Abort(.internalServerError, reason: "Failed to persist user") }
    return UserRecord(id: id, email: user.email, passwordHash: user.passwordHash, fullName: user.fullName, role: user.role)
  }
}

private extension UserRecord {
  init(_ m: User) {
    self.init(id: m.id!, email: m.email, passwordHash: m.passwordHash, fullName: m.fullName, role: m.role)
  }
}
