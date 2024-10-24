// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "DynamicColorBackground",
    platforms: [
        .iOS(.v14), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "DynamicColorBackground",
            targets: ["DynamicColorBackground"]),
    ],
    targets: [
        .target(
            name: "DynamicColorBackground",
            dependencies: []),
        .testTarget(
            name: "DynamicColorBackgroundTests",
            dependencies: ["DynamicColorBackground"]),
    ]
)
