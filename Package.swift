// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "FluentFrontbase",
    products: [
        .library(name: "FluentFrontbase", targets: ["FluentFrontbase"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0"),
        
        // ✳️ Swift ORM framework (queries, models, and relations) for building NoSQL and SQL database integrations.
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),

        // 🇩🇰 A database module for the Frontbase database.
        .package(url: "https://github.com/Oops-AB/Frontbase.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "FluentFrontbase", dependencies: ["Async", "FluentSQL", "Service", "Frontbase"]),
        .testTarget(name: "FluentFrontbaseTests", dependencies: ["FluentBenchmark", "FluentFrontbase", "Frontbase"]),
    ]
)
