//
//  CustomerRequestRepository.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

protocol CustomerRequestRepository: Sendable {
  func create(_ model: CustomerRequest, on db: any Database) async throws -> CustomerRequest
  func find(_ id: UUID, on db: any Database) async throws -> CustomerRequest?
  func list(for customerId: UUID, status: CustomerRequestStatus?, page: Int, per: Int, on db: any Database) async throws -> [CustomerRequest]
  func save(_ model: CustomerRequest, on db: any Database) async throws -> CustomerRequest
}
