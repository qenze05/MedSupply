import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWTKit

public func configure(_ app: Application) async throws {
 
  try configureSQLite(app)
  
  registerAuthMigrations(app)
  registerInventoryMigrations(app)
  registerRequestMigrations(app)
  try await app.autoMigrate()
  
  app.use(.sqlite)
  
  app.use(.live)
  
  registerAuthDependencies(app)
  let secret = Environment.get("JWT_SECRET") ?? "dev_secret_change_me_please_change"
  app.jwt.keys = await JWTKeyCollection().add(hmac: .init(stringLiteral: secret), digestAlgorithm: .sha256, kid: "default")
  
  try routes(app)
  try routesCustomerRequests(app)
}
