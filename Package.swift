// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGenAI",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftGenAI",
            targets: ["SwiftGenAI"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftGenAI"
        ),
        .testTarget(
            name: "SwiftGenAITests",
            dependencies: ["SwiftGenAI"]
        ),
    ]
)

