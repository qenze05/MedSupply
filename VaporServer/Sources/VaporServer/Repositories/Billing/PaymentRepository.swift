//
//  PaymentRepository.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Fluent

protocol PaymentRepository: Sendable {
  @discardableResult func create(_ p: Payment, on db: any Database) async throws -> Payment
  func save(_ p: Payment, on db: any Database) async throws -> Payment
  func find(_ id: UUID, on db: any Database) async throws -> Payment?
  func listForRequest(requestId: UUID, on db: any Database) async throws -> [Payment]
  func listForCustomer(customerId: UUID, on db: any Database) async throws -> [Payment]
}
