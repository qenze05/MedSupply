import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  
  try configureSQLite(app)
  
  registerAuthMigrations(app)
  try await app.autoMigrate()
  
  registerAuthDependencies(app)
  let secret = Environment.get("JWT_SECRET") ?? "dev_secret_change_me_please_change"
  app.jwt.keys = await JWTKeyCollection().add(hmac: .init(stringLiteral: secret), digestAlgorithm: .sha256, kid: "default")
  
  try routes(app)
}
