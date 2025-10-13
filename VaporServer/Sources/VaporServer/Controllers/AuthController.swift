//
//  AuthController.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

struct AuthController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let auth = routes.grouped("api", "auth")
    auth.post("register", use: register)
    auth.post("login", use: login)
    auth.post("refresh", use: refresh)
    auth.post("logout", use: logout)
    auth.get("me", use: me)
  }
  
  func register(_ req: Request) async throws -> AuthResponseDTO {
    try RegisterRequest.validate(content: req)
    let body = try req.content.decode(RegisterRequest.self)
    return try await req.application.authService.register(
      email: body.email,
      password: body.password,
      fullName: body.fullName,
      on: req
    )
  }
  
  func login(_ req: Request) async throws -> AuthResponseDTO {
    try LoginRequest.validate(content: req)
    let body = try req.content.decode(LoginRequest.self)
    return try await req.application.authService.login(
      email: body.email,
      password: body.password,
      on: req
    )
  }
  
  func refresh(_ req: Request) async throws -> TokenPairDTO {
    try RefreshRequest.validate(content: req)
    let body = try req.content.decode(RefreshRequest.self)
    return try await req.application.authService.refresh(using: body.refreshToken, on: req)
  }
  
  func logout(_ req: Request) async throws -> HTTPStatus {
    try RefreshRequest.validate(content: req)
    let body = try req.content.decode(RefreshRequest.self)
    try await req.application.authService.logout(using: body.refreshToken, on: req)
    return .noContent
  }
  
  func me(_ req: Request) async throws -> UserDTO {
    guard let bearer = req.headers.bearerAuthorization?.token else {
      throw Abort(.unauthorized, reason: "Missing Bearer token")
    }
    return try await req.application.authService.me(from: bearer, on: req)
  }
}
