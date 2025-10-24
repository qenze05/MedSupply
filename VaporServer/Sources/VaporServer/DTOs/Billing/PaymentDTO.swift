//
//  PaymentDTO.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

struct CreatePaymentDTO: Content {
  let amount: Int
  let testCard: String
  let currency: String?
}

struct PaymentResponseDTO: Content {
  let id: UUID
  let requestId: UUID
  let amount: Int
  let currency: String
  let status: PaymentStatus
  let failureReason: String?

  init(_ p: Payment) {
    self.id = p.id!
    self.requestId = p.requestId
    self.amount = p.amount
    self.currency = p.currency
    self.status = p.status
    self.failureReason = p.failureReason
  }
}
