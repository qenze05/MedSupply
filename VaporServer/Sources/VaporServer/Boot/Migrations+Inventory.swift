//
//  Migrations+Auth.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor
import Fluent

public func registerInventoryMigrations(_ app: Application) {
  app.migrations.add(CreateProduct())
  app.migrations.add(CreateLocation())
  app.migrations.add(CreateBatch())
  app.migrations.add(CreateStockLevel())
  app.migrations.add(CreateStockMovement())

}
