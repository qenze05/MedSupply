//
//  Inventory Request DTOs
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//

import Vapor

struct InboundRequestDTO: Content {
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let qty: Int
  let reason: String?
  let reference: String?
}

struct OutboundRequestDTO: Content {
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let qty: Int
  let reason: String?
  let reference: String?
}

struct TransferRequestDTO: Content {
  let productID: UUID
  let fromLocationID: UUID
  let toLocationID: UUID
  let batchID: UUID?
  let qty: Int
  let reason: String?
  let reference: String?
}

struct ReserveRequestDTO: Content {
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let qty: Int
  let reason: String?
  let reference: String?
}

struct UnreserveRequestDTO: Content {
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let qty: Int
  let reason: String?
  let reference: String?
}

struct SetOnHandRequestDTO: Content {
  let productID: UUID
  let locationID: UUID
  let batchID: UUID?
  let newValue: Int
  let reason: String?
  let reference: String?
}
