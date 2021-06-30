// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Instagram",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "InstagramCore",
            targets: ["InstagramCore"]),
        .library(
            name: "InstagramLogin",
            targets: ["InstagramLogin"]),
    ],
    dependencies: [
        .package(
            name: "KeychainSwift",
            url: "https://github.com/evgenyneu/keychain-swift.git",
            from: "19.0.0"
        )
    ],
    targets: [
        .target(
            name: "InstagramCore",
            dependencies: ["KeychainSwift"],
            path: "InstagramCore"),
        .target(
            name: "InstagramLogin",
            dependencies: ["InstagramCore"],
            path: "InstagramLogin"),
    ]
)
