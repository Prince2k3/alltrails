// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Core",
            targets: ["Core", "Remote"]),
    ],
    dependencies: [
        
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: []),
        .target(
            name: "Remote",
            dependencies: ["Core"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        .testTarget(
            name: "RemoteTests",
            dependencies: ["Remote"]),
    ]
)
