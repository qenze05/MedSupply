//
//  AuthServiceProtocol.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor
import Foundation


public protocol AuthService: Sendable {
  func register(email: String, password: String, fullName: String?, on req: Request) async throws -> AuthResponseDTO
  func login(email: String, password: String, on req: Request) async throws -> AuthResponseDTO
  func refresh(using refreshToken: String, on req: Request) async throws -> TokenPairDTO
  func logout(using refreshToken: String, on req: Request) async throws
  func me(from accessToken: String, on req: Request) async throws -> UserDTO
}
