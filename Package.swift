// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HPNetwork",
    platforms: [
        .iOS(.v15), .tvOS(.v15), .watchOS(.v6), .macOS(.v12),
    ],
    products: [
        .library(
            name: "HPNetwork",
            targets: ["HPNetwork"]
        ),
        .library(
            name: "HPNetwork-Dynamic",
            type: .dynamic,
            targets: ["HPNetwork"]
        ),
        .library(
            name: "HPNetwork-Static",
            type: .static,
            targets: ["HPNetwork"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
        .package(url: "https://github.com/apple/swift-format", branch: "main"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "HPNetwork",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types")
            ]
        ),
        .testTarget(
            name: "HPNetworkTests",
            dependencies: ["HPNetwork"]
        ),
    ]
)
