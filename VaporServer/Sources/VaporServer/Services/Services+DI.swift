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
    var notification: any NotificationService
  }
  
  private struct AppServicesKey: StorageKey { typealias Value = AppServices }
  var appServices: AppServices {
    get {
      precondition(storage[AppServicesKey.self] != nil, "AppServices is not initialized. Call app.use(.live) before accessing app.appServices.")
      return storage[AppServicesKey.self]!
    }
    set { storage[AppServicesKey.self] = newValue }
  }
  
  
  
  struct AppServicesProvider { let build: (Application) -> AppServices }
  
  static var live: AppServicesProvider {
    .init { app in
      let repos = app.repositories
      let email = SMTPEmailSender(app: app)
      let notif = NotificationServiceImpl(repos: repos, emailSender: email)
      
      return .init(
        inventory: InventoryServiceImpl(repos: repos, notifs: notif),
        notification: notif
      )
    }
  }
  
  func use(_ provider: AppServicesProvider) {
    let built = provider.build(self)
    self.appServices = built
  }
}

extension Request { var appServices: Application.AppServices { application.appServices } }
