//
//  BillingController.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

struct BillingController: RouteCollection, Sendable {
  func boot(routes: any RoutesBuilder) throws {
    let base = routes.grouped("api", "billing")
    let protected = base.grouped(AccessTokenAuthenticator(), UserRecord.guardMiddleware())

    protected.post("requests", ":id", "pay", use: Self.pay)      // POST /api/billing/requests/:id/pay
    protected.get("requests", ":id", "payments", use: Self.list) // GET  /api/billing/requests/:id/payments
    protected.get("payments", use: Self.listAllMine)             // GET /api/billing/payments
  }

  static func pay(_ req: Request) async throws -> PaymentResponseDTO {
    let user = try req.auth.require(UserRecord.self)
    let id   = try req.parameters.require("id", as: UUID.self)
    let dto  = try req.content.decode(CreatePaymentDTO.self)
    return try await req.application.services.billing.pay(requestId: id, by: user, payload: dto, on: req.db)
  }

  static func list(_ req: Request) async throws -> [PaymentResponseDTO] {
    let user = try req.auth.require(UserRecord.self)
    let id   = try req.parameters.require("id", as: UUID.self)
    return try await req.application.services.billing.listPayment(for: id, by: user, on: req.db)
  }
    
  static func listAllMine(_ req: Request) async throws -> [PaymentResponseDTO] {
    let user = try req.auth.require(UserRecord.self)
    return try await req.application.services.billing.listAllPayments(for: user, on: req.db)
  }
}
