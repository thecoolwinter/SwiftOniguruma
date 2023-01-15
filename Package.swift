// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOniguruma",
    products: [
        .library(
            name: "SwiftOniguruma",
            targets: ["SwiftOniguruma"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftOniguruma",
            dependencies: ["SwiftOnigurumaContainer"]
        ),
        .binaryTarget(
            name: "SwiftOnigurumaContainer",
            path: "SwiftOnigurumaContainer.xcframework.zip"
        ),
        .testTarget(
            name: "SwiftOnigurumaTests",
            dependencies: ["SwiftOniguruma"]),
    ]
)
