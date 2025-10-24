//
//  SQLiteNotificationRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 24.10.2025.
//


import Foundation
import Fluent

struct SQLiteNotificationRepository: NotificationRepository, @unchecked Sendable {
  func create(_ rec: NotificationRecord, on db: any Database) async throws -> NotificationRecord {
    try await rec.create(on: db); return rec
  }
  func markSent(_ id: UUID, at: Date, on db: any Database) async throws {
    guard let rec = try await NotificationRecord.find(id, on: db) else { return }
    rec.status = .sent
    rec.sentAt = at
    rec.error = nil
    try await rec.save(on: db)
  }
  func markFailed(_ id: UUID, error: String, on db: any Database) async throws {
    guard let rec = try await NotificationRecord.find(id, on: db) else { return }
    rec.status = .failed
    rec.error = error
    try await rec.save(on: db)
  }
}
