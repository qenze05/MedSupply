//
//  SQLiteRepositoriesProvider.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

extension Application.RepositoriesProvider {
  static var sqlite: Application.RepositoriesProvider {
    .init { _ in
      Application.Repositories(
        product: SQLiteProductRepository(),
        location: SQLiteLocationRepository(),
        batch: SQLiteBatchRepository(),
        stockLevel: SQLiteStockLevelRepository(),
        movement: SQLiteStockMovementRepository(),
        customerRequest: SQLiteCustomerRequestRepository(),
        payment: SQLitePaymentRepository()
      )
    }
  }
}
