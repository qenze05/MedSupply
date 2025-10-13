//
//  AuthResponseDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Vapor

public struct AuthResponseDTO: Content {
  public var user: UserDTO
  public var tokens: TokenPairDTO
  
  
  public init(user: UserDTO, tokens: TokenPairDTO) {
    self.user = user
    self.tokens = tokens
  }
}
