// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "VaporServer",
  platforms: [
    .macOS(.v14),
    .iOS(.v17)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.5.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
    .package(url: "https://github.com/joannis/SMTPKitten.git", from: "0.2.3"),
  ],
  targets: [
    .executableTarget(
      name: "VaporServer",
      dependencies: [
        .product(name: "SMTPKitten", package: "SMTPKitten"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIOPosix", package: "swift-nio"),
        .product(name: "JWT", package: "jwt"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "VaporServerTests",
      dependencies: [
        .target(name: "VaporServer"),
        .product(name: "VaporTesting", package: "vapor"),
      ],
      swiftSettings: swiftSettings
    )
  ]
)

var swiftSettings: [SwiftSetting] { [
  .enableUpcomingFeature("ExistentialAny"),
] }
