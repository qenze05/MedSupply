//
//  Dependencies+Auth.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor

public func registerAuthDependencies(_ app: Application) {
  let userRepo = FluentUserRepository()
  let refreshRepo = FluentRefreshTokenRepository()
  app.authService = AuthServiceImpl(users: userRepo, refreshTokens: refreshRepo)
}
