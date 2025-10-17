//
//  InventoryTests.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 17.10.2025.
//


import XCTest
import VaporTesting
@testable import VaporServer

final class InventoryTests: XCTestCase {

    func testEndToEndInventoryFlow() async throws {
        let app = try await makeTestApp()

        // 1) Admin & User
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

        // 2) Admin: Create Product
        var product: ProductResponseDTO!
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
            product = try res.content.decode(ProductResponseDTO.self)
        })
        XCTAssertNotNil(product)

        // 3) Admin: Create Locations A and B
        var locA: LocationResponseDTO!
        try await app.test(.POST, "/api/inventory/locations", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: adminToken)
            try req.content.encode([
                "code": "WH-A",
                "name": "Warehouse A",
                "address": "Main st 1"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            locA = try res.content.decode(LocationResponseDTO.self)
        })

        var locB: LocationResponseDTO!
        try await app.test(.POST, "/api/inventory/locations", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: adminToken)
            try req.content.encode([
                "code": "WH-B",
                "name": "Warehouse B",
                "address": "Aux st 2"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            locB = try res.content.decode(LocationResponseDTO.self)
        })
        XCTAssertNotNil(locA); XCTAssertNotNil(locB)

        // 4) Admin: Create Batch (optional)
        var batchID: UUID?
        try await app.test(.POST, "/api/inventory/batches", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: adminToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "batchNumber": "BN-2025-10"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let batch = try res.content.decode(BatchResponseDTO.self)
            batchID = batch.id
        })
        XCTAssertNotNil(batchID)

        // 5) User: inbound 100 into WH-A
        var levelA: StockLevelResponseDTO!
        try await app.test(.POST, "/api/inventory/inventory/inbound", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locA.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "100",
                "reason": "supplier receipt",
                "reference": "INV-001"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            levelA = try res.content.decode(StockLevelResponseDTO.self)
            XCTAssertEqual(levelA.onHand, 100)
            XCTAssertEqual(levelA.reserved, 0)
            XCTAssertEqual(levelA.available, 100)
        })

        // 6) reserve 30 at WH-A
        try await app.test(.POST, "/api/inventory/inventory/reserve", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locA.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "30",
                "reason": "order #5001",
                "reference": "SO-5001"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let s = try res.content.decode(StockLevelResponseDTO.self)
            XCTAssertEqual(s.onHand, 100)
            XCTAssertEqual(s.reserved, 30)
            XCTAssertEqual(s.available, 70)
        })

        // 7) outbound 50 from WH-A → consumes 30 reserved + 20 free
        try await app.test(.POST, "/api/inventory/inventory/outbound", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locA.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "50",
                "reason": "shipment #5001",
                "reference": "SO-5001"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let s = try res.content.decode(StockLevelResponseDTO.self)
            XCTAssertEqual(s.onHand, 50)
            XCTAssertEqual(s.reserved, 0)
            XCTAssertEqual(s.available, 50)
        })

        // 8) transfer 40 from WH-A → WH-B
        var pair: [StockLevelResponseDTO] = []
        try await app.test(.POST, "/api/inventory/inventory/transfer", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "fromLocationID": locA.id.uuidString,
                "toLocationID": locB.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "40",
                "reason": "rebalancing",
                "reference": "TR-0001"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            pair = try res.content.decode([StockLevelResponseDTO].self)
            XCTAssertEqual(pair.count, 2)
        })

        // check levels after transfer
        try await app.test(.GET, "/api/inventory/inventory/levels?productID=\(product.id.uuidString)&locationID=\(locA.id.uuidString)", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let arr = try res.content.decode([StockLevelResponseDTO].self)
            XCTAssertEqual(arr.first?.onHand, 10)
        })

        try await app.test(.GET, "/api/inventory/inventory/levels?productID=\(product.id.uuidString)&locationID=\(locB.id.uuidString)", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let arr = try res.content.decode([StockLevelResponseDTO].self)
            XCTAssertEqual(arr.first?.onHand, 40)
        })

        // 9) set-onhand to 35 at WH-B (user → 403, admin → 200)

        // user forbidden
        try await app.test(.POST, "/api/inventory/inventory/set-onhand", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locB.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "newValue": "35",
                "reason": "inventory count",
                "reference": "INV-CNT"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .forbidden)
        })

        // admin allowed
        try await app.test(.POST, "/api/inventory/inventory/set-onhand", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: adminToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locB.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "newValue": "35",
                "reason": "inventory count",
                "reference": "INV-CNT"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let s = try res.content.decode(StockLevelResponseDTO.self)
            XCTAssertEqual(s.onHand, 35)
        })

        // 10) negative checks
        // - insufficient stock
        try await app.test(.POST, "/api/inventory/inventory/outbound", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locA.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "999",
                "reason": "neg",
                "reference": "NEG-1"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .conflict)
        })

        // - invalid qty (0)
        try await app.test(.POST, "/api/inventory/inventory/reserve", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: userToken)
            try req.content.encode([
                "productID": product.id.uuidString,
                "locationID": locA.id.uuidString,
                "batchID": batchID?.uuidString ?? "",
                "qty": "0",
                "reason": "neg",
                "reference": "NEG-2"
            ])
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
      
      try await app.asyncShutdown()
    }
  
}
