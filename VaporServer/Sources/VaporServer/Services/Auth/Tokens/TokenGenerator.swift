//
//  TokenGenerator.swift
//  VaporServer
//
//  Created by Oleksandr Kataskin on 13.10.2025.
//

import Foundation
import CryptoKit

enum TokenGenerator {
  static func opaqueToken(bytes count: Int = 32) -> String {
    let data = Data((0..<count).map { _ in UInt8.random(in: 0...255) })
    return base64url(data)
  }
  
  static func sha256(_ input: String) -> String {
    let digest = SHA256.hash(data: Data(input.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
  }
  
  private static func base64url(_ data: Data) -> String {
    let s = data.base64EncodedString()
    return s.replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
