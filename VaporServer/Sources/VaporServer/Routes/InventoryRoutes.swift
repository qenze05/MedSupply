//
//  InventoryRoutes.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//

import Vapor

func routesInventory(_ app: Application) throws {
  // Базовий префікс
  let base = app.grouped("api", "inventory")

  // 🔐 Захищена група: JWT → UserRecord у req.auth, і guard наявності користувача
  let protected = base.grouped(AccessTokenAuthenticator(), UserRecord.guardMiddleware())

  try protected.register(collection: ProductController())
  try protected.register(collection: LocationController())
  try protected.register(collection: BatchController())
  try protected.register(collection: InventoryController())
}
