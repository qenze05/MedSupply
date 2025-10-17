//
//  BatchCreateDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

struct BatchCreateDTO: Content {
  let productID: UUID
  let batchNumber: String
  let expiresAt: Date?
}

struct BatchResponseDTO: Content {
  let id: UUID
  let productID: UUID
  let batchNumber: String
  let expiresAt: Date?
  let createdAt: Date?
  let updatedAt: Date?

  init(_ b: Batch) {
    id = b.id!
    productID = b.$product.id
    batchNumber = b.batchNumber
    expiresAt = b.expiresAt
    createdAt = b.createdAt
    updatedAt = b.updatedAt
  }
}
