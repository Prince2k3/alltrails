// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "UI",
            targets: ["UI"]),
    ],
    dependencies: [
        .package(path: "../Modules/Core")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: ["Core", "Design"]
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"]
        ),
        .target(name: "Design")
    ]
)
