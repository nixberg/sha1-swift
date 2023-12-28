// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "sha1-swift",
    products: [
        .library(
            name: "SHA1",
            targets: ["SHA1"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/nixberg/blobby-swift",
            .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(
            name: "SHA1"),
        .testTarget(
            name: "SHA1Tests",
            dependencies: [
                .product(name: "Blobby", package: "blobby-swift"),
                "SHA1",
            ],
            resources: [
                .embedInCode("sha1.blb"),
            ]),
    ]
)
