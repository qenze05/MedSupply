//
//  BillingGateway.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

struct GatewayResult: Sendable {
  let providerId: String
  let status: PaymentStatus
  let failureReason: String?
}

protocol BillingGateway: Sendable {
  func charge(amount: Int, currency: String, testCard: String, metadata: [String:String]) async throws -> GatewayResult
}

struct MockBillingGateway: BillingGateway {
  func charge(amount: Int, currency: String, testCard: String, metadata: [String : String]) async throws -> GatewayResult {
    let pid = "mock_\(UUID().uuidString.prefix(8))"
    if testCard.contains("4000") {
      return .init(providerId: pid, status: .failed, failureReason: "card_declined")
    }
    try await Task.sleep(nanoseconds: 150_000_000)
    return .init(providerId: pid, status: .succeeded, failureReason: nil)
  }
}
