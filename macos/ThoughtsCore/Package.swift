// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ThoughtsCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "ThoughtsCore",
            targets: ["ThoughtsCore"]),
    ],
    dependencies: [
        .package(path: "./../dependencies/interact"),
        .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/inseven/glitter.git", .upToNextMajor(from: "0.1.3")),
    ],
    targets: [
        .target(
            name: "ThoughtsCore",
            dependencies: [
                .product(name: "Interact", package: "interact"),
                .product(name: "Sparkle", package: "Sparkle", condition: .when(platforms: [.macOS])),
                .product(name: "Glitter", package: "glitter", condition: .when(platforms: [.macOS])),
            ]
        ),
    ]
)
