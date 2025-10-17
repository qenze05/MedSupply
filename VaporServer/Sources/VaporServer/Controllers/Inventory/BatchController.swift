//
//  BatchController.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import Fluent

struct BatchController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let group = routes.grouped("batches")
    group.post(use: create)
    group.get(use: listByProduct)
    group.get(":id", use: get)
    group.delete(":id", use: delete)
  }

  func create(req: Request) async throws -> BatchResponseDTO {
    let dto = try req.content.decode(BatchCreateDTO.self)
    let model = Batch(productID: dto.productID, batchNumber: dto.batchNumber, expiresAt: dto.expiresAt)
    let saved = try await req.application.repositories.batch.create(model, on: req.db)
    return .init(saved)
  }

  /// GET /batches?productID=...
  func listByProduct(req: Request) async throws -> [BatchResponseDTO] {
    guard let productID = try? req.query.get(UUID.self, at: "productID") else { return [] }
    let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 200)
    let offset = (try? req.query.get(Int.self, at: "offset")) ?? 0
    let items = try await req.application.repositories.batch.list(productID: productID, limit: limit, offset: offset, on: req.db)
    return items.compactMap { $0.id == nil ? nil : BatchResponseDTO($0) }
  }

  func get(req: Request) async throws -> BatchResponseDTO {
    guard let id = req.parameters.get("id", as: UUID.self),
          let item = try await req.application.repositories.batch.find(id: id, on: req.db)
    else { throw RepositoryError.notFound }
    return .init(item)
  }

  func delete(req: Request) async throws -> HTTPStatus {
    guard let id = req.parameters.get("id", as: UUID.self) else { throw RepositoryError.notFound }
    try await req.application.repositories.batch.delete(id: id, on: req.db)
    return .noContent
  }
}
