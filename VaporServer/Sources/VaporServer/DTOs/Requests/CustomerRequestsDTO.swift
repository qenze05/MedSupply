//
//  CustomerRequestsDTO.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

struct CreateCustomerRequestDTO: Content {
  let productId: UUID
  let quantity: Int
  let comment: String?
}

struct CustomerRequestResponseDTO: Content {
  let id: UUID
  let productId: UUID
  let quantity: Int
  let comment: String?
  let status: CustomerRequestStatus
  let createdAt: Date?

  init(from m: CustomerRequest) {
    self.id = m.id!
    self.productId = m.productId
    self.quantity = m.quantity
    self.comment = m.comment
    self.status = m.status
    self.createdAt = m.createdAt
  }
}
