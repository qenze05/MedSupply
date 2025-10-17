//
//  InventoryRoutes.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//

import Vapor

func routesInventory(_ app: Application) throws {
  let base = app.grouped("api", "inventory")
  
  let protected = base.grouped(AccessTokenAuthenticator(), UserRecord.guardMiddleware())
  
  try protected.register(collection: ProductController())
  try protected.register(collection: LocationController())
  try protected.register(collection: BatchController())
  try protected.register(collection: InventoryController())
}
