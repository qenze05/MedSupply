import Vapor
import Fluent

struct InventoryController: RouteCollection {
  func boot(routes: any RoutesBuilder) throws {
    let group = routes.grouped("inventory")

    // Query
    group.get("levels", use: listLevels)           // ?productID&locationID&limit&offset
    group.get("movements", use: listMovements)     // ?productID&locationID&limit&offset

    // Operations
    group.post("inbound", use: inbound)
    group.post("outbound", use: outbound)
    group.post("transfer", use: transfer)
    group.post("reserve", use: reserve)
    group.post("unreserve", use: unreserve)
    group.post("set-onhand", use: setOnHand)
  }

  // MARK: - Query
  func listLevels(req: Request) async throws -> [StockLevelResponseDTO] {
    let productID = try? req.query.get(UUID.self, at: "productID")
    let locationID = try? req.query.get(UUID.self, at: "locationID")
    let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 500)
    let offset = (try? req.query.get(Int.self, at: "offset")) ?? 0

    let rows = try await req.appServices.inventory.listLevels(productID: productID, locationID: locationID, limit: limit, offset: offset, on: req.db)
    return rows.compactMap { $0.id == nil ? nil : StockLevelResponseDTO($0) }
  }

  func listMovements(req: Request) async throws -> [StockMovementResponseDTO] {
    let productID = try? req.query.get(UUID.self, at: "productID")
    let locationID = try? req.query.get(UUID.self, at: "locationID")
    let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 500)
    let offset = (try? req.query.get(Int.self, at: "offset")) ?? 0

    let rows = try await req.appServices.inventory.listMovements(productID: productID, locationID: locationID, limit: limit, offset: offset, on: req.db)
    return rows.compactMap { $0.id == nil ? nil : StockMovementResponseDTO($0) }
  }

  // MARK: - Ops
  func inbound(req: Request) async throws -> StockLevelResponseDTO {
    let userID = try req.requireUserID()
    let dto = try req.content.decode(InboundRequestDTO.self)
    let s = try await req.appServices.inventory.inbound(productID: dto.productID, to: dto.locationID, batchID: dto.batchID, qty: dto.qty,
                                                        reason: dto.reason, reference: dto.reference, performedBy: userID, on: req.db)
    return .init(s)
  }

  func outbound(req: Request) async throws -> StockLevelResponseDTO {
    let userID = try req.requireUserID()
    let dto = try req.content.decode(OutboundRequestDTO.self)
    let s = try await req.appServices.inventory.outbound(productID: dto.productID, from: dto.locationID, batchID: dto.batchID, qty: dto.qty,
                                                         reason: dto.reason, reference: dto.reference, performedBy: userID, on: req.db)
    return .init(s)
  }

  func transfer(req: Request) async throws -> [StockLevelResponseDTO] {
    let userID = try req.requireUserID()
    let dto = try req.content.decode(TransferRequestDTO.self)
    let pair = try await req.appServices.inventory.transfer(productID: dto.productID, from: dto.fromLocationID, to: dto.toLocationID, batchID: dto.batchID, qty: dto.qty,
                                                            reason: dto.reason, reference: dto.reference, performedBy: userID, on: req.db)
    return [.init(pair.from), .init(pair.to)]
  }

  func reserve(req: Request) async throws -> StockLevelResponseDTO {
    let userID = try req.requireUserID()
    let dto = try req.content.decode(ReserveRequestDTO.self)
    let s = try await req.appServices.inventory.reserve(productID: dto.productID, at: dto.locationID, batchID: dto.batchID, qty: dto.qty,
                                                        reason: dto.reason, reference: dto.reference, performedBy: userID, on: req.db)
    return .init(s)
  }

  func unreserve(req: Request) async throws -> StockLevelResponseDTO {
    let userID = try req.requireUserID()
    let dto = try req.content.decode(UnreserveRequestDTO.self)
    let s = try await req.appServices.inventory.unreserve(productID: dto.productID, at: dto.locationID, batchID: dto.batchID, qty: dto.qty,
                                                          reason: dto.reason, reference: dto.reference, performedBy: userID, on: req.db)
    return .init(s)
  }

  func setOnHand(req: Request) async throws -> StockLevelResponseDTO {
    let user = try req.requireUser()
    guard user.isAdmin else { throw Abort(.forbidden, reason: "Only admin can set on-hand (inventory correction)") }

    let dto = try req.content.decode(SetOnHandRequestDTO.self)
    let s = try await req.appServices.inventory.setOnHand(productID: dto.productID, at: dto.locationID, batchID: dto.batchID, to: dto.newValue,
                                                          reason: dto.reason, reference: dto.reference, performedBy: user.id, on: req.db)
    return .init(s)
  }
}
