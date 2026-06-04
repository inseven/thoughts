// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ThoughtsCore",
    platforms: [
        .macOS(.v14),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "ThoughtsCore",
            targets: ["ThoughtsCore"]),
    ],
    dependencies: [
        .package(path: "./../dependencies/diligence"),
        .package(path: "./../dependencies/interact"),
        .package(path: "./../dependencies/FrontmatterSwift"),
        .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMajor(from: "2.7.1")),
        .package(url: "https://github.com/inseven/glitter.git", .upToNextMajor(from: "0.1.3")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "5.1.2")),
    ],
    targets: [
        .target(
            name: "ThoughtsCore",
            dependencies: [
                .product(name: "Diligence", package: "diligence"),
                .product(name: "Interact", package: "interact"),
                .product(name: "FrontmatterSwift", package: "FrontmatterSwift"),
                .product(name: "Sparkle", package: "Sparkle", condition: .when(platforms: [.macOS])),
                .product(name: "Glitter", package: "glitter", condition: .when(platforms: [.macOS])),
                .product(name: "Yams", package: "Yams"),
            ],
            resources: [
                .process("Licenses"),
            ],
        ),
    ]
)
