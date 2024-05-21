// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TraceInfoManager",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
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
