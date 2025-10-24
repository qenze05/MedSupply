import Vapor
import SMTPKitten
import NIO

protocol EmailSender: Sendable {
  func send(to email: String, subject: String, html: String, plain: String?) async throws
}

struct SMTPEmailSender: EmailSender, @unchecked Sendable {
  private let eventLoopGroup: any EventLoopGroup
  private let host: String
  private let port: Int
  private let username: String
  private let password: String
  private let fromEmail: String
  private let fromName: String?
  private let useTLS: Bool
  
  init(app: Application) {
    self.eventLoopGroup = app.eventLoopGroup
    self.host = Environment.get("SMTP_HOST") ?? "localhost"
    self.port = Int(Environment.get("SMTP_PORT") ?? "1025") ?? 1025
    self.username = Environment.get("SMTP_USER") ?? ""
    self.password = Environment.get("SMTP_PASS") ?? ""
    self.fromEmail = Environment.get("SMTP_FROM") ?? "no-reply@medsupply.com"
    self.fromName  = Environment.get("SMTP_FROM_NAME")
    self.useTLS = (Environment.get("SMTP_TLS") ?? "false").lowercased() != "false"
  }
  
  func send(to email: String, subject: String, html: String, plain: String?) async throws {
    let el = eventLoopGroup.next()
    
    let sslMode: SMTPSSLMode = useTLS
    ? .startTLS(configuration: .default)
    : .insecure
    
    let client = try await SMTPClient.connect(
      hostname: host,
      port: port,
      ssl: sslMode,
      on: el
    )
    
    try await client.login(user: username, password: password)
    
    let content: Mail.Content = {
      if let plain = plain {
        return .alternative(plain, html: html)
      } else {
        return .html(html)
      }
    }()
    
    let from = MailUser(name: fromName, email: fromEmail)
    let to   = MailUser(name: nil, email: email)
    
    let mail = Mail(
      from: from,
      to: [to],
      cc: [],
      subject: subject,
      content: content
    )
    
    try await client.sendMail(mail)
  }
}
