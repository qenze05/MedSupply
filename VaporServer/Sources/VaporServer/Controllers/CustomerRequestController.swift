//
//  CustomerRequestController.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

struct CustomerRequestController: RouteCollection, Sendable {
  func boot(routes: any RoutesBuilder) throws {
    let base = routes.grouped("api", "customer-requests")
    let protected = base.grouped(AccessTokenAuthenticator(), UserRecord.guardMiddleware())

    protected.post(use: Self.create)                       // POST /api/customer-requests
    protected.get(use: Self.listMine)                      // GET  /api/customer-requests
    protected.get(":id", use: Self.details)                // GET  /api/customer-requests/:id
    protected.post(":id", "cancel", use: Self.cancel)      // POST /api/customer-requests/:id/cancel
  }

  // MARK: Handlers (static — не захватывают self)

  static func create(_ req: Request) async throws -> CustomerRequestResponseDTO {
    let user = try req.auth.require(UserRecord.self)
    let dto  = try req.content.decode(CreateCustomerRequestDTO.self)
    return try await req.application.services.customerRequest
      .create(for: user, payload: dto, on: req.db)
  }

  static func listMine(_ req: Request) async throws -> [CustomerRequestResponseDTO] {
    let user   = try req.auth.require(UserRecord.self)
    let status = try? req.query.get(CustomerRequestStatus.self, at: "status")
    let page   = (try? req.query.get(Int.self, at: "page")) ?? 1
    let per    = (try? req.query.get(Int.self, at: "per"))  ?? 20
    return try await req.application.services.customerRequest
      .listMine(for: user, status: status, page: page, per: per, on: req.db)
  }

  static func details(_ req: Request) async throws -> CustomerRequestResponseDTO {
    let user = try req.auth.require(UserRecord.self)
    let id   = try req.parameters.require("id", as: UUID.self)
    return try await req.application.services.customerRequest
      .details(id: id, for: user, on: req.db)
  }

  static func cancel(_ req: Request) async throws -> CustomerRequestResponseDTO {
    let user = try req.auth.require(UserRecord.self)
    let id   = try req.parameters.require("id", as: UUID.self)
    return try await req.application.services.customerRequest
      .cancel(id: id, by: user, on: req.db)
  }
}
