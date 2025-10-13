//
//  Migrations+Auth.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

public func registerAuthMigrations(_ app: Application) {
    app.migrations.add(CreateUser())
    app.migrations.add(CreateRefreshToken())
}
