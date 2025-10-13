//
//  AuthServiceImpl.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor
import JWT

public struct AuthServiceImpl: AuthService, Sendable {
  private let users: any UserRepository
  private let refreshTokens: any RefreshTokenRepository
  private let accessTTL: TimeInterval
  private let refreshTTL: TimeInterval
  private let defaultRole: String
  
  public init(
    users: any UserRepository,
    refreshTokens: any RefreshTokenRepository,
    accessTTL: TimeInterval = 15 * 60,
    refreshTTL: TimeInterval = 30 * 24 * 60 * 60,
    defaultRole: String = "user"
  ) {
    self.users = users
    self.refreshTokens = refreshTokens
    self.accessTTL = accessTTL
    self.refreshTTL = refreshTTL
    self.defaultRole = defaultRole
  }
  
  public func register(email: String, password: String, fullName: String?, on req: Request) async throws -> AuthResponseDTO {
    if try await users.findByEmail(email.lowercased(), on: req) != nil {
      throw Abort(.conflict, reason: "Email already in use")
    }
    let hash = try Bcrypt.hash(password)
    let user = try await users.create(email: email.lowercased(), passwordHash: hash, fullName: fullName, role: defaultRole, on: req)
    return try await issueTokensAndBuildResponse(for: user, on: req)
  }
  
  public func login(email: String, password: String, on req: Request) async throws -> AuthResponseDTO {
    guard let user = try await users.findByEmail(email.lowercased(), on: req),
          try Bcrypt.verify(password, created: user.passwordHash) else {
      throw Abort(.unauthorized, reason: "Invalid credentials")
    }
    return try await issueTokensAndBuildResponse(for: user, on: req)
  }
  
  public func refresh(using refreshToken: String, on req: Request) async throws -> TokenPairDTO {
    let tokenHash = TokenGenerator.sha256(refreshToken)
    guard let record = try await refreshTokens.findActive(byTokenHash: tokenHash, on: req),
          let user = try await users.findByID(record.userId, on: req) else {
      throw Abort(.unauthorized, reason: "Invalid or expired refresh token")
    }
    try await refreshTokens.revoke(tokenId: record.id, on: req) // rotate
    return try await issueTokenPair(for: user, on: req)
  }
  
  public func logout(using refreshToken: String, on req: Request) async throws {
    let tokenHash = TokenGenerator.sha256(refreshToken)
    guard let record = try await refreshTokens.findActive(byTokenHash: tokenHash, on: req) else { return }
    try await refreshTokens.revoke(tokenId: record.id, on: req)
  }
  
  public func me(from accessToken: String, on req: Request) async throws -> UserDTO {
    let payload = try await req.jwt.verify(accessToken, as: AccessTokenPayload.self)
    guard let userId = UUID(uuidString: payload.subject.value),
          let user = try await users.findByID(userId, on: req) else {
      throw Abort(.unauthorized, reason: "Invalid token user")
    }
    return toDTO(user)
  }
  
  // MARK: - Helpers
  private func issueTokensAndBuildResponse(for user: UserRecord, on req: Request) async throws -> AuthResponseDTO {
    let pair = try await issueTokenPair(for: user, on: req)
    return AuthResponseDTO(user: toDTO(user), tokens: pair)
  }
  
  private func issueTokenPair(for user: UserRecord, on req: Request) async throws -> TokenPairDTO {
    let expDate = Date().addingTimeInterval(accessTTL)
    let payload = AccessTokenPayload(
        subject: SubjectClaim(value: user.id.uuidString),
        email: user.email,
        role: user.role,
        expiration: ExpirationClaim(value: expDate)
    )
    let access = try await req.jwt.sign(payload, kid: "default")
    
    let refresh = TokenGenerator.opaqueToken()
    let refreshHash = TokenGenerator.sha256(refresh)
    _ = try await refreshTokens.create(for: user.id, tokenHash: refreshHash, expiresAt: Date().addingTimeInterval(refreshTTL), on: req)
    
    return TokenPairDTO(accessToken: access, refreshToken: refresh, accessTokenExpiresAt: expDate)
  }
  
  private func toDTO(_ user: UserRecord) -> UserDTO {
    .init(id: user.id, email: user.email, fullName: user.fullName, role: user.role)
  }
}
