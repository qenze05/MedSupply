import Vapor
import Fluent

protocol NotificationService: Sendable {
  @discardableResult
  func notifyEmail(
    to user: User,
    subject: String,
    html: String,
    plain: String?,
    on db: any Database
  ) async throws -> NotificationRecord

  func notifyEmails(
    to users: [User],
    subject: String,
    html: String,
    plain: String?,
    on db: any Database
  ) async throws
}

struct NotificationServiceImpl: NotificationService, @unchecked Sendable {
  private let repos: Application.Repositories
  private let emailSender: any EmailSender

  init(repos: Application.Repositories, emailSender: any EmailSender) {
    self.repos = repos
    self.emailSender = emailSender
  }

  @discardableResult
  func notifyEmail(
    to user: User,
    subject: String,
    html: String,
    plain: String?,
    on db: any Database
  ) async throws -> NotificationRecord {
    let rec = NotificationRecord(
      recipientID: try user.requireID(),
      recipientEmail: user.email,
      channel: .email,
      status: .pending,
      subject: subject,
      body: html
    )
    let saved = try await repos.notification.create(rec, on: db)
    do {
      try await emailSender.send(to: user.email, subject: subject, html: html, plain: plain)
      try await repos.notification.markSent(try saved.requireID(), at: Date(), on: db)
    } catch {
      try await repos.notification.markFailed(try saved.requireID(), error: "\(error)", on: db)
      throw error
    }
    return saved
  }

  func notifyEmails(
    to users: [User],
    subject: String,
    html: String,
    plain: String?,
    on db: any Database
  ) async throws {
    for u in users {
      _ = try await notifyEmail(to: u, subject: subject, html: html, plain: plain, on: db)
    }
  }
}
