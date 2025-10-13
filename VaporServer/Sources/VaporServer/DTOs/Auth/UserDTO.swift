//
//  UserDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public struct UserDTO: Content {
  public var id: UUID?
  public var email: String
  public var fullName: String?
  public var role: String
  
  
  public init(id: UUID? = nil, email: String, fullName: String? = nil, role: String) {
    self.id = id
    self.email = email
    self.fullName = fullName
    self.role = role
  }
}
