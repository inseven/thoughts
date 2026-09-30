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
        .package(path: "./../dependencies/HighlightedTextEditor"),
        .package(url: "https://github.com/sparkle-project/Sparkle", .upToNextMajor(from: "2.10.0")),
        .package(url: "https://github.com/inseven/glitter.git", .upToNextMajor(from: "0.1.3")),
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "5.4.0")),
        .package(url: "https://github.com/jbmorley/TagField.git", .upToNextMajor(from: "0.0.11")),
        .package(url: "https://github.com/inseven/diligence.git", from: "2.0.1"),
        .package(url: "https://github.com/inseven/interact.git", from: "3.10.5"),
        .package(url: "https://github.com/jbmorley/FrontmatterSwift.git", from: "0.2.1"),
    ],
    targets: [
        .target(
            name: "ThoughtsCore",
            dependencies: [
                .product(name: "Diligence", package: "diligence"),
                .product(name: "FrontmatterSwift", package: "FrontmatterSwift"),
                .product(name: "HighlightedTextEditor", package: "HighlightedTextEditor"),
                .product(name: "Interact", package: "interact"),
                .product(name: "TagField", package: "TagField"),
                .product(name: "Yams", package: "Yams"),
            ],
            resources: [
                .process("Licenses"),
            ],
        ),
    ]
)
