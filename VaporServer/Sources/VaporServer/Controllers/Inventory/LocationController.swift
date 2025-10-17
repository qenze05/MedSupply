import Vapor
import Fluent

struct LocationController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let group = routes.grouped("locations")
    group.post(use: create)
    group.get(use: list)
    group.get(":id", use: get)
    group.patch(":id", use: update)
    group.delete(":id", use: delete)
  }

  func create(req: Request) async throws -> LocationResponseDTO {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can create locations") }

    let dto = try req.content.decode(LocationCreateDTO.self)
    let model = Location(code: dto.code, name: dto.name, address: dto.address, isActive: true)
    let saved = try await req.application.repositories.location.create(model, on: req.db)
    return .init(saved)
  }

  func list(req: Request) async throws -> [LocationResponseDTO] {
    let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 200)
    let offset = (try? req.query.get(Int.self, at: "offset")) ?? 0
    let items = try await req.application.repositories.location.list(limit: limit, offset: offset, on: req.db)
    return items.compactMap { $0.id == nil ? nil : LocationResponseDTO($0) }
  }

  func get(req: Request) async throws -> LocationResponseDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let item = try await req.application.repositories.location.find(id: id, on: req.db)
    else { throw RepositoryError.notFound }
    return .init(item)
  }

  func update(req: Request) async throws -> LocationResponseDTO {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can update locations") }

    guard let id = req.parameters.get("id", as: UUID.self),
          let item = try await req.application.repositories.location.find(id: id, on: req.db)
    else { throw RepositoryError.notFound }

    let dto = try req.content.decode(LocationUpdateDTO.self)
    if let name = dto.name { item.name = name }
    if let address = dto.address { item.address = address }
    let saved = try await req.application.repositories.location.update(item, on: req.db)
    return .init(saved)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can delete locations") }

    guard let id = req.parameters.get("id", as: UUID.self) else { throw RepositoryError.notFound }
    try await req.application.repositories.location.delete(id: id, on: req.db)
    return .noContent
  }
}
