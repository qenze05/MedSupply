//
//  UserRecord.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Foundation

public struct UserRecord: Sendable {
  public let id: UUID
  public let email: String
  public let passwordHash: String
  public let fullName: String?
  public let role: String
}
