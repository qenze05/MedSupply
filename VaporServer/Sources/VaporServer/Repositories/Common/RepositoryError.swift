//
//  RepositoryError.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor

enum RepositoryError: Error, AbortError {
  case notFound
  case duplicate
  case invalidState(String)
  
  var reason: String {
    switch self {
      case .notFound: return "Resource not found"
      case .duplicate: return "Duplicate resource"
      case .invalidState(let msg): return "Invalid state: \(msg)"
    }
  }
  var status: HTTPResponseStatus {
    switch self {
      case .notFound: return .notFound
      case .duplicate: return .conflict
      case .invalidState: return .badRequest
    }
  }
}
