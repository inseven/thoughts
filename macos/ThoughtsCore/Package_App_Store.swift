// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ThoughtsCore",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ThoughtsCore",
            targets: ["ThoughtsCore"]),
    ],
    dependencies: [
        .package(path: "./../dependencies/interact"),
        .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/inseven/glitter.git", .upToNextMajor(from: "0.1.1")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "5.1.2")),
    ],
    targets: [
        .target(
            name: "ThoughtsCore",
            dependencies: [
                .product(name: "Interact", package: "interact"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
    ]
)
