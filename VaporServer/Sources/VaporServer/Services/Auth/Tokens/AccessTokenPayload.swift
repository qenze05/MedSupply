//
//  AccessTokenPayload.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import JWTKit
import Foundation

struct AccessTokenPayload: JWTPayload, Sendable {
  let subject: SubjectClaim
  let email: String
  let role: String
  let expiration: ExpirationClaim
  
  func verify(using algorithm: some JWTAlgorithm) async throws {
    try expiration.verifyNotExpired()
  }
}

