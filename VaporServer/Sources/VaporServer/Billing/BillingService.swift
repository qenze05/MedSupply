//
//  BillingService.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor
import Fluent

protocol BillingService: Sendable {
  func pay(requestId: UUID, by user: UserRecord, payload: CreatePaymentDTO, on db: any Database) async throws -> PaymentResponseDTO
  func listPayment(for requestId: UUID, by user: UserRecord, on db: any Database) async throws -> [PaymentResponseDTO]
  func listAllPayments(for user: UserRecord, on db: any Database) async throws -> [PaymentResponseDTO]
}

struct BillingServiceImpl: BillingService {
    
    private let requests: any CustomerRequestRepository
    private let payments: any PaymentRepository
    private let gateway: any BillingGateway

  init(app: Application) {
    self.requests = app.repositories.customerRequest
    self.payments = app.repositories.payment
    self.gateway  = MockBillingGateway()
  }

  func pay(requestId: UUID, by user: UserRecord, payload: CreatePaymentDTO, on db: any Database) async throws -> PaymentResponseDTO {
    guard let req = try await requests.find(requestId, on: db) else { throw Abort(.notFound) }
    guard req.customerId == user.id else { throw Abort(.forbidden) }
    guard req.status == .approved else {
      throw Abort(.conflict, reason: "request must be approved to pay")
    }

    let currency = payload.currency ?? "USD"
    var payment = Payment(requestId: requestId, amount: payload.amount, currency: currency, status: .processing)
    try await payments.create(payment, on: db)

    let res = try await gateway.charge(amount: payload.amount, currency: currency, testCard: payload.testCard, metadata: [
      "requestId": requestId.uuidString
    ])

    payment.providerId = res.providerId
    payment.status = res.status
    payment.failureReason = res.failureReason
    payment = try await payments.save(payment, on: db)

    if res.status == .succeeded {
      req.status = .fulfilled
      _ = try await requests.save(req, on: db)
    }

    return PaymentResponseDTO(payment)
  }

  func listPayment(for requestId: UUID, by user: UserRecord, on db: any Database) async throws -> [PaymentResponseDTO] {
    guard let req = try await requests.find(requestId, on: db) else { throw Abort(.notFound) }
    guard req.customerId == user.id else { throw Abort(.forbidden) }
    let arr = try await payments.listForRequest(requestId: requestId, on: db)
    return arr.map(PaymentResponseDTO.init(_:))
  }
    
  func listAllPayments(for user: UserRecord, on db: any Database) async throws -> [PaymentResponseDTO] {
    let arr = try await payments.listForCustomer(customerId: user.id, on: db)
    return arr.map(PaymentResponseDTO.init(_:))
  }
}
