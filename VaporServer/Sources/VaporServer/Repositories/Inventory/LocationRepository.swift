//
//  LocationRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

protocol LocationRepository: Sendable {
  func create(_ location: Location, on db: any Database) async throws -> Location
  func find(id: UUID, on db: any Database) async throws -> Location?
  func findByCode(_ code: String, on db: any Database) async throws -> Location?
  func list(limit: Int, offset: Int, on db: any Database) async throws -> [Location]
  func update(_ location: Location, on db: any Database) async throws -> Location
  func delete(id: UUID, on db: any Database) async throws
}
