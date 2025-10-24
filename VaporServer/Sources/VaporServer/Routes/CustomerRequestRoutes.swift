//
//  CustomerRequestRoutes.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

func routesCustomerRequests(_ app: Application) throws {
  try app.register(collection: CustomerRequestController())
}
