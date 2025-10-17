//
//  StockMovementResponseDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

struct StockMovementResponseDTO: Content {
  let id: UUID
  let productID: UUID
  let fromLocationID: UUID?
  let toLocationID: UUID?
  let batchID: UUID?
  let quantity: Int
  let kind: StockMovement.Kind
  let reason: String?
  let reference: String?
  let performedByUserID: UUID?
  let createdAt: Date?
  
  init(_ m: StockMovement) {
    id = m.id!
    productID = m.$product.id
    fromLocationID = m.$fromLocation.id
    toLocationID = m.$toLocation.id
    batchID = m.$batch.id
    quantity = m.quantity
    kind = m.kind
    reason = m.reason
    reference = m.reference
    performedByUserID = m.performedByUserID
    createdAt = m.createdAt
  }
}
