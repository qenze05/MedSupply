//
//  LocationCreateDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

struct LocationCreateDTO: Content {
  let code: String
  let name: String
  let address: String?
}

struct LocationUpdateDTO: Content {
  let name: String?
  let address: String?
}

struct LocationResponseDTO: Content {
  let id: UUID
  let code: String
  let name: String
  let address: String?
  let createdAt: Date?
  let updatedAt: Date?
  
  init(_ l: Location) {
    id = l.id!
    code = l.code
    name = l.name
    address = l.address
    createdAt = l.createdAt
    updatedAt = l.updatedAt
  }
}
