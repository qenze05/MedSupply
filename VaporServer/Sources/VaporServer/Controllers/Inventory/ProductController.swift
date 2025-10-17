import Vapor
import Fluent

struct ProductController: RouteCollection {

  func boot(routes: any RoutesBuilder) throws {
    let group = routes.grouped("products")
    group.post(use: create)
    group.get(use: list)
    group.get(":id", use: get)
    group.patch(":id", use: update)
    group.delete(":id", use: delete)
  }

  func create(req: Request) async throws -> ProductResponseDTO {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can create products") }

    let dto = try req.content.decode(ProductCreateDTO.self)
    let model = Product(
      sku: dto.sku,
      name: dto.name,
      desc: dto.desc,
      unit: dto.unit,
      createdByUserID: user.id
    )
    let saved = try await req.application.repositories.product.create(model, on: req.db)
    return .init(saved)
  }

  func list(req: Request) async throws -> [ProductResponseDTO] {
    let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 200)
    let offset = (try? req.query.get(Int.self, at: "offset")) ?? 0
    let items = try await req.application.repositories.product.list(limit: limit, offset: offset, on: req.db)
    return items.compactMap { $0.id == nil ? nil : ProductResponseDTO($0) }
  }

  func get(req: Request) async throws -> ProductResponseDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let item = try await req.application.repositories.product.find(id: id, on: req.db)
    else { throw RepositoryError.notFound }
    return .init(item)
  }

  func update(req: Request) async throws -> ProductResponseDTO {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can update products") }

    guard let id = req.parameters.get("id", as: UUID.self),
          let item = try await req.application.repositories.product.find(id: id, on: req.db)
    else { throw RepositoryError.notFound }

    let dto = try req.content.decode(ProductUpdateDTO.self)
    if let name = dto.name { item.name = name }
    if let desc = dto.desc { item.desc = desc }
    if let unit = dto.unit { item.unit = unit }
    let saved = try await req.application.repositories.product.update(item, on: req.db)
    return .init(saved)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can delete products") }

    guard let id = req.parameters.get("id", as: UUID.self) else { throw RepositoryError.notFound }
    try await req.application.repositories.product.delete(id: id, on: req.db)
    return .noContent
  }
}
