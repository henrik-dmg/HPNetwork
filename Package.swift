// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HPNetwork",
    platforms: [
        .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macOS(.v10_15),
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
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "HPNetwork"),
        .testTarget(
            name: "HPNetworkTests",
            dependencies: ["HPNetwork"]
        ),
    ]
)
