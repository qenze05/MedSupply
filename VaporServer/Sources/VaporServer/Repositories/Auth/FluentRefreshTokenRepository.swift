//
//  FluentRefreshTokenRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

public struct FluentRefreshTokenRepository: RefreshTokenRepository, Sendable {
  public init() {}
  
  public func create(for userId: UUID, tokenHash: String, expiresAt: Date, on req: Request) async throws -> RefreshTokenRecord {
    let model = RefreshToken(userID: userId, tokenHash: tokenHash, expiresAt: expiresAt)
    try await model.save(on: req.db)
    guard let id = model.id else { throw Abort(.internalServerError, reason: "Failed to persist refresh token") }
    return RefreshTokenRecord(id: id, userId: userId, tokenHash: tokenHash, expiresAt: expiresAt, revokedAt: nil)
  }
  
  public func findActive(byTokenHash tokenHash: String, on req: Request) async throws -> RefreshTokenRecord? {
    let now = Date()
    if let m = try await RefreshToken.query(on: req.db)
      .filter(\.$tokenHash == tokenHash)
      .filter(\.$revokedAt == nil)
      .filter(\.$expiresAt > now)
      .first()
    {
      return RefreshTokenRecord(id: m.id!, userId: m.$user.id, tokenHash: m.tokenHash, expiresAt: m.expiresAt, revokedAt: m.revokedAt)
    }
    return nil
  }
  
  public func revoke(tokenId: UUID, on req: Request) async throws {
    guard let model = try await RefreshToken.find(tokenId, on: req.db) else { return }
    model.revokedAt = Date()
    try await model.save(on: req.db)
  }
  
  public func revokeAll(for userId: UUID, on req: Request) async throws {
    try await RefreshToken.query(on: req.db)
      .filter(\.$user.$id == userId)
      .filter(\.$revokedAt == nil)
      .set(\.$revokedAt, to: Date())
      .update()
  }
}
