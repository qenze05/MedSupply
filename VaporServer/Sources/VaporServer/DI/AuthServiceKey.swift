//
//  AuthServiceKey.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public extension Application {
  private struct AuthServiceKey: StorageKey { public typealias Value = any AuthService }
  
  var authService: any AuthService {
    get {
      guard let service = self.storage[AuthServiceKey.self] else {
        fatalError("AuthService is not configured. Register a concrete implementation in configure.swift")
      }
      return service
    }
    set { self.storage[AuthServiceKey.self] = newValue }
  }
}
