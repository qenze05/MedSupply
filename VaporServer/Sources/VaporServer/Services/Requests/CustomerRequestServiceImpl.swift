//
//  CustomerRequestServiceImpl.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

struct CustomerRequestServiceImpl: CustomerRequestService {

    private let productRepo: any ProductRepository
    private let requestRepo: any CustomerRequestRepository

  init(app: Application) {
    self.productRepo  = app.repositories.product
    self.requestRepo  = app.repositories.customerRequest
  }

  // MARK: - Create

  func create(
    for user: UserRecord,
    payload: CreateCustomerRequestDTO,
    on db: any Database
  ) async throws -> CustomerRequestResponseDTO {
    guard payload.quantity > 0 else {
      throw Abort(.badRequest, reason: "quantity must be greater than 0")
    }
    guard try await productRepo.find(id: payload.productId, on: db) != nil else {
      throw Abort(.notFound, reason: "product not found")
    }

    let model = CustomerRequest(
      customerId: user.id,
      productId: payload.productId,
      quantity: payload.quantity,
      comment: payload.comment,
      status: .pending
    )

    let saved = try await requestRepo.create(model, on: db)
    guard saved.id != nil else {
      throw Abort(.internalServerError, reason: "request did not get an id after save")
    }

    return CustomerRequestResponseDTO(from: saved)
  }

  // MARK: - List mine

  func listMine(
    for user: UserRecord,
    status: CustomerRequestStatus?,
    page: Int,
    per: Int,
    on db: any Database
  ) async throws -> [CustomerRequestResponseDTO] {
    let items = try await requestRepo.list(
      for: user.id,
      status: status,
      page: page,
      per: per,
      on: db
    )
    return items.map { CustomerRequestResponseDTO(from: $0) }
  }

  // MARK: - Details

  func details(
    id: UUID,
    for user: UserRecord,
    on db: any Database
  ) async throws -> CustomerRequestResponseDTO {
    guard let found = try await requestRepo.find(id, on: db) else {
      throw Abort(.notFound)
    }
    guard found.customerId == user.id else {
      throw Abort(.forbidden, reason: "not an owner of the request")
    }
    return CustomerRequestResponseDTO(from: found)
  }

  // MARK: - Cancel

  func cancel(
    id: UUID,
    by user: UserRecord,
    on db: any Database
  ) async throws -> CustomerRequestResponseDTO {
    guard let found = try await requestRepo.find(id, on: db) else {
      throw Abort(.notFound)
    }
    guard found.customerId == user.id else {
      throw Abort(.forbidden, reason: "not an owner of the request")
    }
    guard found.status == .pending else {
      throw Abort(.conflict, reason: "only pending requests can be cancelled")
    }

    found.status = .cancelled
    let saved = try await requestRepo.save(found, on: db)
    return CustomerRequestResponseDTO(from: saved)
  }
}


extension CustomerRequestServiceImpl {
  func adminList(
    status: CustomerRequestStatus?,
    customerId: UUID?,
    productId: UUID?,
    page: Int,
    per: Int,
    on db: any Database
  ) async throws -> [CustomerRequestResponseDTO] {
    let items = try await requestRepo.listAll(
      status: status, customerId: customerId, productId: productId,
      page: page, per: per, on: db
    )
    return items.map(CustomerRequestResponseDTO.init(from:))
  }

  func adminSetStatus(
    id: UUID,
    to newStatus: CustomerRequestStatus,
    by admin: UserRecord,
    on db: any Database
  ) async throws -> CustomerRequestResponseDTO {
    guard let model = try await requestRepo.find(id, on: db) else {
      throw Abort(.notFound)
    }

    let old = model.status
    let allowed: Set<CustomerRequestStatus> = {
      switch old {
      case .pending:  return [.approved, .declined]
      case .approved: return [.fulfilled, .declined]
      case .declined, .fulfilled, .cancelled: return []
      }
    }()

    guard allowed.contains(newStatus) else {
      throw Abort(.conflict, reason: "invalid status transition \(old.rawValue) → \(newStatus.rawValue)")
    }

    model.status = newStatus
    let saved = try await requestRepo.save(model, on: db)
    return CustomerRequestResponseDTO(from: saved)
  }
}
