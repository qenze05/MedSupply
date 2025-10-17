//
//  Request+CurrentUser.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

extension Request {
  var currentUser: UserRecord? { auth.get(UserRecord.self) }
  
  func requireUser() throws -> UserRecord {
    try auth.require(UserRecord.self)
  }
  
  func requireUserID() throws -> UUID {
    try requireUser().id
  }
}

extension UserRecord {
  var isAdmin: Bool { role.lowercased() == "admin" }
}
