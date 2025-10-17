//
//  StockLevelResponseDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

struct StockLevelResponseDTO: Content {
  let id: UUID
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let onHand: Int
  let reserved: Int
  let available: Int
  let updatedAt: Date?

  init(_ s: StockLevel) {
    id = s.id!
    productID = s.$product.id
    locationID = s.$location.id
    batchID = s.$batch.id
    onHand = s.onHand
    reserved = s.reserved
    available = s.onHand - s.reserved
    updatedAt = s.updatedAt
  }
}
