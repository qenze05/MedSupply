//
//  Services.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//

import Vapor

extension Application {
  struct AppServices {
    var inventory: any InventoryService
  }
  
  private struct AppServicesKey: StorageKey {
    typealias Value = AppServices
  }
  
  var appServices: AppServices {
    get {
      guard let value = storage[AppServicesKey.self] else {
        fatalError("AppServices not configured. Call app.appServices.use(...) in configure.swift")
      }
      return value
    }
    set { storage[AppServicesKey.self] = newValue }
  }
  
  struct AppServicesProvider {
    let make: (Application) -> AppServices
  }
  
  func use(_ provider: AppServicesProvider) {
    self.appServices = provider.make(self)
  }
}

extension Application.AppServicesProvider {
  static var live: Application.AppServicesProvider {
    .init { app in
        .init(
          inventory: InventoryServiceImpl(repos: app.repositories)
        )
    }
  }
}

extension Request {
  var appServices: Application.AppServices { application.appServices }
}
