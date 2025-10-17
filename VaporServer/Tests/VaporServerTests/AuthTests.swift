//
//  AuthTests.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import XCTest
import VaporTesting
@testable import VaporServer

final class AuthTests: XCTestCase {
  
  func testRegisterLoginAndUnauthorizedAccess() async throws {
    let app = try await makeTestApp()
    
    // Реєстрація + логін
    let userToken = try await registerAndLogin(app,
                                               fullName: TestUsers.userName,
                                               email: TestUsers.userEmail,
                                               password: TestUsers.userPass,
                                               role: "user")
    XCTAssertFalse(userToken.isEmpty)
    
    // Спроба доступу без токена до захищеного інвентарного ресурсу → 401/403
    try await app.test(.GET, "/api/inventory/inventory/levels", afterResponse: { res in
      XCTAssertTrue([.unauthorized, .forbidden].contains(res.status))
    })
    
    // Доступ з токеном → 200
    try await app.test(.GET, "/api/inventory/inventory/levels", beforeRequest: { req in
      req.headers.bearerAuthorization = .init(token: userToken)
    }, afterResponse: { res in
      XCTAssertEqual(res.status, .ok)
    })
    
    try await app.asyncShutdown()
  }
  
  func testAdminRequiredForProductCreate() async throws {
    let app = try await makeTestApp()
    
    let adminToken = try await registerAndLogin(app,
                                                fullName: TestUsers.adminName,
                                                email: TestUsers.adminEmail,
                                                password: TestUsers.adminPass,
                                                role: "admin")
    
    let userToken  = try await registerAndLogin(app,
                                                fullName: TestUsers.userName,
                                                email: TestUsers.userEmail,
                                                password: TestUsers.userPass,
                                                role: "user")
    
    // Користувач без адмін ролі — 403
    try await app.test(.POST, "/api/inventory/products", beforeRequest: { req in
      req.headers.bearerAuthorization = .init(token: userToken)
      try req.content.encode([
        "sku": "MASK-N95-S",
        "name": "Mask N95 Small",
        "desc": "N95 respirator",
        "unit": "piece"
      ])
    }, afterResponse: { res in
      XCTAssertEqual(res.status, .forbidden)
    })
    
    // Адмін — 200 і повертає продукт
    try await app.test(.POST, "/api/inventory/products", beforeRequest: { req in
      req.headers.bearerAuthorization = .init(token: adminToken)
      try req.content.encode([
        "sku": "MASK-N95-S",
        "name": "Mask N95 Small",
        "desc": "N95 respirator",
        "unit": "piece"
      ])
    }, afterResponse: { res in
      XCTAssertEqual(res.status, .ok)
      _ = try res.content.decode(ProductResponseDTO.self)
    })
    
    try await app.asyncShutdown()
  }
}
