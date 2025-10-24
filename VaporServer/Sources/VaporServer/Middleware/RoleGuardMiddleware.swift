//
//  RoleGuardMiddleware.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

struct RoleGuardMiddleware: AsyncMiddleware, Sendable {
  let allowed: Set<String>
  init(_ allowed: [String]) { self.allowed = Set(allowed) }

    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
    let user = try req.auth.require(UserRecord.self)
    guard allowed.contains(user.role) else {
      throw Abort(.forbidden, reason: "requires roles: \(allowed.joined(separator: ","))")
    }
    return try await next.respond(to: req)
  }
}
