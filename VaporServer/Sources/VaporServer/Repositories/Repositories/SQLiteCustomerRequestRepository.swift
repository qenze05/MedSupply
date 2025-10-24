//
//  SQLiteCustomerRequestRepository.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

struct SQLiteCustomerRequestRepository: CustomerRequestRepository {
  func create(_ model: CustomerRequest, on db: any Database) async throws -> CustomerRequest {
    try await model.save(on: db)
    return model
  }

  func find(_ id: UUID, on db: any Database) async throws -> CustomerRequest? {
    try await CustomerRequest.find(id, on: db)
  }

  func list(for customerId: UUID, status: CustomerRequestStatus?, page: Int, per: Int, on db: any Database) async throws -> [CustomerRequest] {
    var q = CustomerRequest.query(on: db)
      .filter(\.$customerId == customerId)
      .sort(\.$createdAt, .descending)

    if let status { q = q.filter(\.$status == status) }

    let safePer = min(100, max(1, per))
    let safePage = max(1, page)
    let lower = (safePage - 1) * safePer
    return try await q.range(lower..<(lower + safePer)).all()
  }

  func save(_ model: CustomerRequest, on db: any Database) async throws -> CustomerRequest {
    try await model.save(on: db)
    return model
  }
}
