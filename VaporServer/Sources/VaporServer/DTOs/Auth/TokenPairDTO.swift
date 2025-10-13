//
//  TokenPairDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor

public struct TokenPairDTO: Content {
  public var accessToken: String
  public var refreshToken: String
  public var accessTokenExpiresAt: Date
  
  
  public init(accessToken: String, refreshToken: String, accessTokenExpiresAt: Date) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.accessTokenExpiresAt = accessTokenExpiresAt
  }
}
