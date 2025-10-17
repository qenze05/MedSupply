//
//  Product.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor
import Fluent

final class Product: Model, Content {
  static let schema = "products"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: FieldKeys.sku)
  var sku: String
  
  @Field(key: FieldKeys.name)
  var name: String
  
  @OptionalField(key: FieldKeys.desc)
  var desc: String?
  
  @Field(key: FieldKeys.unit)
  var unit: UnitOfMeasure
  
  @OptionalField(key: FieldKeys.createdByUserID)
  var createdByUserID: UUID?
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  @Timestamp(key: FieldKeys.deletedAt, on: .delete)
  var deletedAt: Date?
  
  // Relations
  @Children(for: \.$product) var batches: [Batch]
  @Children(for: \.$product) var stockLevels: [StockLevel]
  @Children(for: \.$product) var movements: [StockMovement]
  
  init() {}
  
  init(id: UUID? = nil, sku: String, name: String, desc: String?, unit: UnitOfMeasure, createdByUserID: UUID?) {
    self.id = id
    self.sku = sku
    self.name = name
    self.desc = desc
    self.unit = unit
    self.createdByUserID = createdByUserID
  }
}

extension Product {
  enum FieldKeys {
    static let sku = FieldKey("sku")
    static let name = FieldKey("name")
    static let desc = FieldKey("desc")
    static let unit = FieldKey("unit")
    static let createdByUserID = FieldKey("created_by_user_id")
    static let createdAt = FieldKey("created_at")
    static let updatedAt = FieldKey("updated_at")
    static let deletedAt = FieldKey("deleted_at")
  }
  
  enum UnitOfMeasure: String, Codable, CaseIterable, Content {
    case piece, pack, box, ml, l, g, kg, tablet, dose
  }
}

extension Product: @unchecked Sendable {}
