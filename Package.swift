// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "sha1-swift",
    products: [
        .library(
            name: "SHA1",
            targets: ["SHA1"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"3.0.0"),
        .package(url: "https://github.com/nixberg/crypto-traits-swift", from: "0.1.0"),
        .package(url: "https://github.com/nixberg/endianbytes-swift", from: "0.3.0"),
        .package(url: "https://github.com/nixberg/hexstring-swift", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "SHA1",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Duplex", package: "crypto-traits-swift"),
                .product(name: "EndianBytes", package: "endianbytes-swift"),
            ]),
        .testTarget(
            name: "SHA1Tests",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "HexString", package: "hexstring-swift"),
                "SHA1",
            ]),
    ]
)
