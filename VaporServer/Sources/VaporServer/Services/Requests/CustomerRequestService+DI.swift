//
//  CustomerRequestService+DI.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent


protocol CustomerRequestService: Sendable {
  func create(for user: UserRecord, payload: CreateCustomerRequestDTO, on db: any Database) async throws -> CustomerRequestResponseDTO
  func listMine(for user: UserRecord, status: CustomerRequestStatus?, page: Int, per: Int, on db: any Database) async throws -> [CustomerRequestResponseDTO]
  func details(id: UUID, for user: UserRecord, on db: any Database) async throws -> CustomerRequestResponseDTO
  func cancel(id: UUID, by user: UserRecord, on db: any Database) async throws -> CustomerRequestResponseDTO
}

extension Application.Services {
  private struct CustomerRequestServiceKey: StorageKey {
    typealias Value = any CustomerRequestService
  }

  var customerRequest: any CustomerRequestService {
    if let cached = application.storage[CustomerRequestServiceKey.self] {
      return cached
    }
    let created = CustomerRequestServiceImpl(app: application)
    application.storage[CustomerRequestServiceKey.self] = created
    return created
  }
}
