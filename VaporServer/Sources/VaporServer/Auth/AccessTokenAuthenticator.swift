//
//  AccessTokenAuthenticator.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import JWTKit

// Дамо змогу логінити UserRecord у req.auth
extension UserRecord: Authenticatable {}

struct AccessTokenAuthenticator: AsyncBearerAuthenticator {
  func authenticate(bearer: BearerAuthorization, for req: Request) async throws {
    // Перевіряємо підпис і строк дії токена
    let payload = try await req.jwt.verify(bearer.token, as: AccessTokenPayload.self)
    guard let userID = UUID(uuidString: payload.subject.value) else { return }

    // Завантажимо користувача з БД (через поточний репозиторій)
    if let user = try await FluentUserRepository().findByID(userID, on: req) {
      req.auth.login(user)
    }
  }
}
