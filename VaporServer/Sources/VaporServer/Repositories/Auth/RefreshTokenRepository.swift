//
//  RefreshTokenRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public protocol RefreshTokenRepository: Sendable {
  func create(for userId: UUID, tokenHash: String, expiresAt: Date, on req: Request) async throws -> RefreshTokenRecord
  func findActive(byTokenHash tokenHash: String, on req: Request) async throws -> RefreshTokenRecord?
  func revoke(tokenId: UUID, on req: Request) async throws
  func revokeAll(for userId: UUID, on req: Request) async throws
}
