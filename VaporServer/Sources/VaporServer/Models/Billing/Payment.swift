//
//  Payment.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Fluent
import Vapor

enum PaymentStatus: String, Codable, CaseIterable, Content {
  case created
  case processing
  case succeeded
  case failed
  case cancelled
}

final class Payment: Model, Content, @unchecked Sendable {
  static let schema = "payments"

  @ID(key: .id) var id: UUID?
  @Field(key: "request_id") var requestId: UUID
  @Field(key: "amount") var amount: Int
  @Field(key: "currency") var currency: String
  @Enum(key: "status") var status: PaymentStatus
  @OptionalField(key: "provider_id") var providerId: String?
  @OptionalField(key: "failure_reason") var failureReason: String?

  @Timestamp(key: "created_at", on: .create) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

  init() {}
  init(id: UUID? = nil, requestId: UUID, amount: Int, currency: String = "USD", status: PaymentStatus) {
    self.id = id
    self.requestId = requestId
    self.amount = amount
    self.currency = currency
    self.status = status
  }
}
