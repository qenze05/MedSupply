//
//  Database+SQLite.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent
import FluentSQLiteDriver

public func configureSQLite(_ app: Application) throws {
  app.databases.use(.sqlite(.file("medsupply.sqlite")), as: .sqlite)
}
