//
//  Request+CurrentUser.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

extension Request {
  /// Поточний автентифікований користувач (якщо є)
  var currentUser: UserRecord? { auth.get(UserRecord.self) }

  /// Вимагає наявність автентифікованого користувача
  func requireUser() throws -> UserRecord {
    try auth.require(UserRecord.self)
  }

  /// Зручний доступ до user.id
  func requireUserID() throws -> UUID {
    try requireUser().id
  }
}

extension UserRecord {
  var isAdmin: Bool { role.lowercased() == "admin" }
}
