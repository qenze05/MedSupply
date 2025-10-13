//
//  UserRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public protocol UserRepository: Sendable {
  func findByEmail(_ email: String, on req: Request) async throws -> UserRecord?
  func findByID(_ id: UUID, on req: Request) async throws -> UserRecord?
  func create(email: String, passwordHash: String, fullName: String?, role: String, on req: Request) async throws -> UserRecord
}
