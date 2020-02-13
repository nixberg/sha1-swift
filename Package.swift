// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SHA1",
    products: [
        .library(
            name: "SHA1",
            targets: ["SHA1"]),
    ],
    targets: [
        .target(
            name: "SHA1"),
        .testTarget(
            name: "SHA1Tests",
            dependencies: ["SHA1"]),
    ]
)
