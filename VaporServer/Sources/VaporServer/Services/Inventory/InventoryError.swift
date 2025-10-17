//
//  InventoryError.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

enum InventoryError: Error, AbortError, Sendable {
  case invalidQuantity
  case notEnoughStock
  case batchMismatch
  case unknown(String)

  var reason: String {
    switch self {
    case .invalidQuantity: return "Quantity must be a positive integer."
    case .notEnoughStock:  return "Not enough available stock."
    case .batchMismatch:   return "Batch does not belong to the given product."
    case .unknown(let m):  return m
    }
  }

  var status: HTTPResponseStatus {
    switch self {
    case .invalidQuantity: return .badRequest
    case .notEnoughStock:  return .conflict
    case .batchMismatch:   return .badRequest
    case .unknown:         return .internalServerError
    }
  }
}
