//
//  Repositories.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

extension Application {
  struct Repositories {
    var product: any ProductRepository
    var location: any LocationRepository
    var batch: any BatchRepository
    var stockLevel: any StockLevelRepository
    var movement: any StockMovementRepository
  }
  
  private struct RepositoriesKey: StorageKey {
    typealias Value = Repositories
  }
  
  var repositories: Repositories {
    get {
      guard let value = storage[RepositoriesKey.self] else {
        fatalError("Repositories not configured. Call app.repositories.use(...) in configure.swift")
      }
      return value
    }
    set { storage[RepositoriesKey.self] = newValue }
  }
  
  struct RepositoriesProvider {
    let make: (Application) -> Repositories
  }
  
  func use(_ provider: RepositoriesProvider) {
    self.repositories = provider.make(self)
  }
}

extension Request {
  var repositories: Application.Repositories { application.repositories }
}
