//
//  File.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

enum CustomerRequestStatus: String, Codable, CaseIterable, Content {
  case pending, approved, declined, fulfilled, cancelled
}

final class CustomerRequest: Model, Content, @unchecked Sendable {
  static let schema = "customer_requests"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "customer_id")
  var customerId: UUID

  @Field(key: "product_id")
  var productId: UUID

  @Field(key: "quantity")
  var quantity: Int

  @OptionalField(key: "comment")
  var comment: String?

  @Enum(key: "status")
  var status: CustomerRequestStatus

  @Timestamp(key: "created_at", on: .create)
  var createdAt: Date?

  @Timestamp(key: "updated_at", on: .update)
  var updatedAt: Date?

  init() {}

  init(
    id: UUID? = nil,
    customerId: UUID,
    productId: UUID,
    quantity: Int,
    comment: String?,
    status: CustomerRequestStatus = .pending
  ) {
    self.id = id
    self.customerId = customerId
    self.productId = productId
    self.quantity = quantity
    self.comment = comment
    self.status = status
  }
}
