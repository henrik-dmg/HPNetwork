// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HPNetwork",
    platforms: [
        .iOS(.v9), .macOS(.v10_11), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(name: "HPNetwork", targets: ["HPNetwork"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "HPNetwork"),
        .testTarget(
            name: "HPNetworkTests",
            dependencies: ["HPNetwork"]
		)
    ]
)
