import XCTest
import VaporTesting
import Vapor
import Fluent
import FluentSQLiteDriver
import JWTKit

@testable import VaporServer

enum TestUsers {
  static let adminEmail = "admin@example.com"
  static let adminPass  = "Password1!"
  static let adminName  = "Admin Adminovich"
  
  static let userEmail  = "user@example.com"
  static let userPass   = "Password1!"
  static let userName   = "Inventory Operator"
}

struct LoginResponse: Content {
  struct Tokens: Content { let accessToken: String }
  struct User: Content { let id: UUID; let email: String; let role: String }
  let user: User
  let tokens: Tokens
}

struct ProductResponseDTO: Content {
  let id: UUID
  let sku: String
  let name: String
  let desc: String?
  let unit: String
}

struct LocationResponseDTO: Content {
  let id: UUID
  let code: String
  let name: String
}

struct BatchResponseDTO: Content {
  let id: UUID
  let productID: UUID
  let batchNumber: String
}

struct StockLevelResponseDTO: Content {
  let id: UUID
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let onHand: Int
  let reserved: Int
  let available: Int
}

func makeTestApp() async throws -> Application {
  let app = try await Application.make(.testing)
  
  let secret = "test_secret_change_me"
  app.jwt.keys = await JWTKeyCollection()
    .add(hmac: .init(stringLiteral: secret), digestAlgorithm: .sha256, kid: "default")
  
  app.databases.use(.sqlite(.memory), as: .sqlite)
  
  registerAuthMigrations(app)
  registerInventoryMigrations(app)
  
  try await app.autoMigrate()
  
  // DI
  app.use(.sqlite)
  app.use(.live)
  
  // Auth DI
  registerAuthDependencies(app)
  
  try routes(app)
  return app
}


func registerAndLogin(_ app: Application, fullName: String, email: String, password: String, role: String) async throws -> String {
  try await app.test(.POST, "/api/auth/register", beforeRequest: { req in
    try req.content.encode([
      "email": email,
      "password": password,
      "fullName": fullName,
      "role": role
    ])
  }, afterResponse: { res in
    XCTAssertEqual(res.status, .ok, "Register failed: \(res.status)")
  })
  
  if let u = try await User.query(on: app.db)
    .filter(\.$email == email)
    .first()
  {
    u.role = role
    try await u.save(on: app.db)
  } else {
    XCTFail("User not found after register")
  }
  
  var accessToken = ""
  try await app.test(.POST, "/api/auth/login", beforeRequest: { req in
    try req.content.encode([
      "email": email,
      "password": password
    ])
  }, afterResponse: { res in
    XCTAssertEqual(res.status, .ok, "Login failed: \(res.status)")
    let login = try res.content.decode(LoginResponse.self)
    accessToken = login.tokens.accessToken
  })
  
  return accessToken
}
