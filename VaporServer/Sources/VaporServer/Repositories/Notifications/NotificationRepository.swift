//
//  NotificationRepository.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 24.10.2025.
//


import Foundation
import Fluent

protocol NotificationRepository: Sendable {
  @discardableResult
  func create(_ rec: NotificationRecord, on db: any Database) async throws -> NotificationRecord
  func markSent(_ id: UUID, at: Date, on db: any Database) async throws
  func markFailed(_ id: UUID, error: String, on db: any Database) async throws
}
