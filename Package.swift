// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "sha1-swift",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SHA1",
            targets: ["SHA1"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "2.0.0"),
        .package(url: "https://github.com/nixberg/crypto-traits-swift", "0.1.0"..<"0.2.0"),
        .package(url: "https://github.com/nixberg/endianbytes-swift", "0.5.0"..<"0.6.0"),
        .package(url: "https://github.com/nixberg/fixed-size-array-swift", branch: "main"),
        .package(url: "https://github.com/nixberg/hexstring-swift", "0.5.0"..<"0.6.0"),
    ],
    targets: [
        .target(
            name: "SHA1",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Duplex", package: "crypto-traits-swift"),
                .product(name: "EndianBytes", package: "endianbytes-swift"),
                .product(name: "FixedSizeArray", package: "fixed-size-array-swift"),
            ]),
        .testTarget(
            name: "SHA1Tests",
            dependencies: [
                .product(name: "Crypto",    package: "swift-crypto"),
                .product(name: "HexString", package: "hexstring-swift"),
                "SHA1",
            ]),
    ]
)
