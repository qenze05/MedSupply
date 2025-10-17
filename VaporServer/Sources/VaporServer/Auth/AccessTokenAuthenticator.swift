//
//  AccessTokenAuthenticator.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import JWTKit

extension UserRecord: Authenticatable {}

struct AccessTokenAuthenticator: AsyncBearerAuthenticator {
  func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
    let payload = try await req.jwt.verify(bearer.token, as: AccessTokenPayload.self)
    guard let userID = UUID(uuidString: payload.subject.value) else { return }
    
    if let user = try await FluentUserRepository().findByID(userID, on: req) {
      req.auth.login(user)
    }
  }
}
