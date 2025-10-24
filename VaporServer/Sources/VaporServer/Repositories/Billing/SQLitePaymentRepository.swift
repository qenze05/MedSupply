//
//  SQLitePaymentRepository.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Fluent

struct SQLitePaymentRepository: PaymentRepository {
  func listForCustomer(customerId: UUID, on db: any FluentKit.Database) async throws -> [Payment] {
    try await Payment.query(on: db)
      .join(CustomerRequest.self, on: \Payment.$requestId == \CustomerRequest.$id)
      .filter(CustomerRequest.self, \.$customerId == customerId)
      .sort(\Payment.$createdAt, .descending)
      .all()
  }
    
  func create(_ p: Payment, on db: any Database) async throws -> Payment {
    try await p.create(on: db); return p
  }
  func save(_ p: Payment, on db: any Database) async throws -> Payment {
    try await p.update(on: db); return p
  }
  func find(_ id: UUID, on db: any Database) async throws -> Payment? {
    try await Payment.find(id, on: db)
  }
  func listForRequest(requestId: UUID, on db: any Database) async throws -> [Payment] {
    try await Payment.query(on: db)
      .filter(\.$requestId == requestId)
      .sort(\.$createdAt, .descending)
      .all()
  }
}
