// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Restaurants", platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Restaurants",
            targets: ["Restaurants"]),
    ],
    dependencies: [
        .package(path: "../Modules/Core"),
        .package(path: "../Modules/UI")
    ],
    targets: [
        .target(
            name: "Restaurants",
            dependencies: ["Core", "UI"]),
        .testTarget(
            name: "RestaurantsTests",
            dependencies: ["Restaurants"]),
    ]
)
