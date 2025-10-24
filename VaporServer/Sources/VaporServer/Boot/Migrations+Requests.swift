//
//  File.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

func registerRequestMigrations(_ app: Application) {
  app.migrations.add(CreateCustomerRequest())
}
