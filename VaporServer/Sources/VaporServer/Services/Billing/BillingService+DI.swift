//
//  BillingService+DI.swift
//  VaporServer
//
//  Created by Andrii Prokofiev on 24.10.2025.
//

import Vapor

extension Application.Services {
  private struct BillingServiceKey: StorageKey { typealias Value = any BillingService }
  var billing: any BillingService {
    if let v = application.storage[BillingServiceKey.self] { return v }
    let v = BillingServiceImpl(app: application)
    application.storage[BillingServiceKey.self] = v
    return v
  }
}
