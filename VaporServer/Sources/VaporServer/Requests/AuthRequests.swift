//
//  AuthRequests.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public struct RegisterRequest: Content {
  public let email: String
  public let password: String
  public let fullName: String?
}

public struct LoginRequest: Content {
  public let email: String
  public let password: String
}

public struct RefreshRequest: Content {
  public let refreshToken: String
}

extension RegisterRequest: Validatable {
  public static func validations(_ v: inout Validations) {
    v.add("email", as: String.self, is: .email)
    v.add("password", as: String.self, is: .count(8...128))
    v.add("fullName", as: String?.self, is: .nil || .count(1...128))
  }
}

extension LoginRequest: Validatable {
  public static func validations(_ v: inout Validations) {
    v.add("email", as: String.self, is: .email)
    v.add("password", as: String.self, is: .count(1...128))
  }
}

extension RefreshRequest: Validatable {
  public static func validations(_ v: inout Validations) {
    v.add("refreshToken", as: String.self, is: .count(10...))
  }
}
