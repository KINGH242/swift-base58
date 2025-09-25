// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftBase58",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "SwiftBase58",
            targets: ["SwiftBase58"]
        ),
    ],
    dependencies: [
        // Big integer arithmetic used by the Base58 implementation
        .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMinor(from: "5.3.0")),
        // Provides Crypto compatible APIs on Linux
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.15.1"),
    ],
    targets: [
        .target(
            name: "SwiftBase58",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                // Only link UncommonCrypto on Linux; on Apple platforms, CommonCrypto is available.
                .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux])),
            ]
        ),
        .testTarget(
            name: "SwiftBase58Tests",
            dependencies: ["SwiftBase58"]
        ),
    ]
)
