//
//  StockMovement.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Vapor
import Fluent

final class StockMovement: Model, Content {
  static let schema = "stock_movements"
  
  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: FieldKeys.productID)
  var product: Product
  
  @OptionalParent(key: FieldKeys.fromLocationID)
  var fromLocation: Location?
  
  @OptionalParent(key: FieldKeys.toLocationID)
  var toLocation: Location?
  
  @OptionalParent(key: FieldKeys.batchID)
  var batch: Batch?
  
  @Field(key: FieldKeys.quantity)
  var quantity: Int
  
  @Field(key: FieldKeys.kind)
  var kind: Kind
  
  @OptionalField(key: FieldKeys.reason)
  var reason: String?
  
  @OptionalField(key: FieldKeys.reference)
  var reference: String?
  
  @OptionalField(key: FieldKeys.performedByUserID)
  var performedByUserID: UUID?
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  init() {}
  
  init(id: UUID? = nil,
       productID: UUID,
       fromLocationID: UUID?,
       toLocationID: UUID?,
       batchID: UUID?,
       quantity: Int,
       kind: Kind,
       reason: String?,
       reference: String?,
       performedByUserID: UUID?) {
    self.id = id
    self.$product.id = productID
    self.$fromLocation.id = fromLocationID
    self.$toLocation.id = toLocationID
    self.$batch.id = batchID
    self.quantity = quantity
    self.kind = kind
    self.reason = reason
    self.reference = reference
    self.performedByUserID = performedByUserID
  }
}

extension StockMovement {
  enum FieldKeys {
    static let productID = FieldKey("product_id")
    static let fromLocationID = FieldKey("from_location_id")
    static let toLocationID = FieldKey("to_location_id")
    static let batchID = FieldKey("batch_id")
    static let quantity = FieldKey("quantity")
    static let kind = FieldKey("kind")
    static let reason = FieldKey("reason")
    static let reference = FieldKey("reference")
    static let performedByUserID = FieldKey("performed_by_user_id")
    static let createdAt = FieldKey("created_at")
  }
  
  enum Kind: String, Codable, CaseIterable, Content {
    case inbound      // оприбуткування (поставка)
    case outbound     // відпуск/списання
    case transfer     // переміщення між локаціями
    case adjustment   // коригування
    case inventory    // інвентаризація (фіксація факту)
  }
}

extension StockMovement: @unchecked Sendable {}
