//
//  NotificationChannel.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 24.10.2025.
//


import Vapor
import Fluent

enum NotificationChannel: String, Codable, CaseIterable, Content { case email }
enum NotificationStatus: String, Codable, CaseIterable, Content { case pending, sent, failed }

final class NotificationRecord: Model, Content, @unchecked Sendable {
  static let schema = "notifications"
  
  @ID(key: .id) var id: UUID?
  
  @Parent(key: "recipient_user_id") var recipient: User
  @Field(key: "recipient_email") var recipientEmail: String
  
  @Enum(key: "channel") var channel: NotificationChannel
  @Enum(key: "status") var status: NotificationStatus
  
  @Field(key: "subject") var subject: String
  @Field(key: "body") var body: String
  
  @OptionalField(key: "error") var error: String?
  
  @Timestamp(key: "created_at", on: .create) var createdAt: Date?
  @Timestamp(key: "sent_at", on: .none) var sentAt: Date?
  
  init() {}
  init(recipientID: UUID, recipientEmail: String, channel: NotificationChannel = .email,
       status: NotificationStatus = .pending, subject: String, body: String) {
    self.$recipient.id = recipientID
    self.recipientEmail = recipientEmail
    self.channel = channel
    self.status = status
    self.subject = subject
    self.body = body
  }
}
