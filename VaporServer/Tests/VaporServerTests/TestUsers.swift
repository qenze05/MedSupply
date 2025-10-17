import XCTest
import VaporTesting
import Vapor
import Fluent
import FluentSQLiteDriver
import JWTKit

@testable import VaporServer // ← заміни на назву твого target, якщо інша

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
    // ✅ async-safe factory
    let app = try await Application.make(.testing)

    // JWT keys
    let secret = "test_secret_change_me"
    app.jwt.keys = await JWTKeyCollection()
        .add(hmac: .init(stringLiteral: secret), digestAlgorithm: .sha256, kid: "default")

    // In-memory SQLite
    app.databases.use(.sqlite(.memory), as: .sqlite)

    // Migrations (use yours if you have helpers)
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateBatch())
    app.migrations.add(CreateStockLevel())
    app.migrations.add(CreateStockMovement())

    try await app.autoMigrate()

    // DI (same as prod)
    app.use(.sqlite)
    app.use(.live)

    // Routes
    try routes(app)

    return app
}

// Хелпер: реєстрація + логін (повертає токен)
func registerAndLogin(_ app: Application, fullName: String, email: String, password: String, role: String) async throws -> String {
    // register
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

    // login
    var accessToken = ""
    try await app.test(.POST, "/api/auth/login", beforeRequest: { req in
        try req.content.encode([
            "email": email,
            "password": password
        ])
    }, afterResponse: { res in
        XCTAssertEqual(res.status, .ok)
        let login = try res.content.decode(LoginResponse.self)
        accessToken = login.tokens.accessToken
        XCTAssertEqual(login.user.role.lowercased(), role.lowercased())
    })
    return accessToken
}
