//
//  SQLiteLocationRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import Fluent

struct SQLiteLocationRepository: LocationRepository {
  func create(_ location: Location, on db: any Database) async throws -> Location {
    if let _ = try await Location.query(on: db).filter(\.$code == location.code).first() {
      throw RepositoryError.duplicate
    }
    try await location.create(on: db)
    return location
  }

  func find(id: UUID, on db: any Database) async throws -> Location? {
    try await Location.find(id, on: db)
  }

  func findByCode(_ code: String, on db: any Database) async throws -> Location? {
    try await Location.query(on: db).filter(\.$code == code).first()
  }

  func list(limit: Int, offset: Int, on db: any Database) async throws -> [Location] {
    try await Location.query(on: db).range(offset..<(offset+limit)).all()
  }

  func update(_ location: Location, on db: any Database) async throws -> Location {
    try await location.update(on: db)
    return location
  }

  func delete(id: UUID, on db: any Database) async throws {
    guard let found = try await Location.find(id, on: db) else { throw RepositoryError.notFound }
    try await found.delete(on: db)
  }
}
