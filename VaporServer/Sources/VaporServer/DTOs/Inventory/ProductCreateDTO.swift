//
//  ProductCreateDTO.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//

import Vapor

struct ProductCreateDTO: Content {
  let sku: String
  let name: String
  let desc: String?
  let unit: Product.UnitOfMeasure
}

struct ProductUpdateDTO: Content {
  let name: String?
  let desc: String?
  let unit: Product.UnitOfMeasure?
}

struct ProductResponseDTO: Content {
  let id: UUID
  let sku: String
  let name: String
  let desc: String?
  let unit: Product.UnitOfMeasure
  let createdAt: Date?
  let updatedAt: Date?

  init(_ p: Product) {
    self.id = p.id!
    self.sku = p.sku
    self.name = p.name
    self.desc = p.desc
    self.unit = p.unit
    self.createdAt = p.createdAt
    self.updatedAt = p.updatedAt
  }
}
