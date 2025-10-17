//
//  StockLevel.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import Fluent

final class StockLevel: Model, Content {
  static let schema = "stock_levels"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: FieldKeys.productID)
  var product: Product
  
  @Parent(key: FieldKeys.locationID)
  var location: Location
  
  @OptionalParent(key: FieldKeys.batchID)
  var batch: Batch?
  
  // Для медичних виробів часто достатньо цілих одиниць
  @Field(key: FieldKeys.onHand)
  var onHand: Int
  
  @Field(key: FieldKeys.reserved)
  var reserved: Int
  
  @OptionalField(key: FieldKeys.reorderLevel)
  var reorderLevel: Int?
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  init() {}
  
  init(id: UUID? = nil, productID: UUID, locationID: UUID, batchID: UUID?, onHand: Int = 0, reserved: Int = 0, reorderLevel: Int? = nil) {
    self.id = id
    self.$product.id = productID
    self.$location.id = locationID
    self.$batch.id = batchID
    self.onHand = onHand
    self.reserved = reserved
    self.reorderLevel = reorderLevel
  }
}

extension StockLevel {
  enum FieldKeys {
    static let productID = FieldKey("product_id")
    static let locationID = FieldKey("location_id")
    static let batchID = FieldKey("batch_id")
    static let onHand = FieldKey("on_hand")
    static let reserved = FieldKey("reserved")
    static let reorderLevel = FieldKey("reorder_level")
    static let createdAt = FieldKey("created_at")
    static let updatedAt = FieldKey("updated_at")
  }
}

extension StockLevel: @unchecked Sendable {}
