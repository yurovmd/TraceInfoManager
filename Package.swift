// swift-tools-version: 5.5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TraceInfoManager",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TraceInfoManager",
            targets: ["TraceInfoManager"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TraceInfoManager",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "TraceInfoManagerTests",
            dependencies: ["TraceInfoManager"],
            path: "Tests"),
    ]
)
