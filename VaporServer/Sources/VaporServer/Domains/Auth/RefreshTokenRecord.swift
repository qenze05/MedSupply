//
//  RefreshTokenRecord.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Foundation

public struct RefreshTokenRecord: Sendable {
  public let id: UUID
  public let userId: UUID
  public let tokenHash: String
  public let expiresAt: Date
  public let revokedAt: Date?
}
