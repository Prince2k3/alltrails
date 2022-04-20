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
            targets: ["Core", "Local", "Remote", "Preview"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: []),
        .target(
            name: "Local",
            dependencies: ["Core"]),
        .target(
            name: "Remote",
            dependencies: ["Core"]),
        .target(
            name: "Preview",
            dependencies: ["Core"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        .testTarget(
            name: "LocalTests",
            dependencies: ["Local"]),
        .testTarget(
            name: "RemoteTests",
            dependencies: ["Remote"]),
    ]
)
