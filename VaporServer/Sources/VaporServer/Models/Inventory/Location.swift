//
//  Location.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//


import Vapor
import Fluent

final class Location: Model, Content {
  static let schema = "locations"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: FieldKeys.code)
  var code: String
  
  @Field(key: FieldKeys.name)
  var name: String
  
  @OptionalField(key: FieldKeys.address)
  var address: String?
  
  @Field(key: FieldKeys.isActive)
  var isActive: Bool
  
  @Timestamp(key: FieldKeys.createdAt, on: .create)
  var createdAt: Date?
  
  @Timestamp(key: FieldKeys.updatedAt, on: .update)
  var updatedAt: Date?
  
  @Timestamp(key: FieldKeys.deletedAt, on: .delete)
  var deletedAt: Date?
  
  @Children(for: \.$location)
  var stockLevels: [StockLevel]
  
  init() {}
  
  init(id: UUID? = nil, code: String, name: String, address: String?, isActive: Bool = true) {
    self.id = id
    self.code = code
    self.name = name
    self.address = address
    self.isActive = isActive
  }
}

extension Location {
  enum FieldKeys {
    static let code = FieldKey("code")
    static let name = FieldKey("name")
    static let address = FieldKey("address")
    static let isActive = FieldKey("is_active")
    static let createdAt = FieldKey("created_at")
    static let updatedAt = FieldKey("updated_at")
    static let deletedAt = FieldKey("deleted_at")
  }
}

extension Location: @unchecked Sendable {}
