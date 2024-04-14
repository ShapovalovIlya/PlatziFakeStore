// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlatziFakeStore",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "PlatziFakeStore", targets: ["PlatziFakeStore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ShapovalovIlya/SwiftFP.git", branch: "main"),
//        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "PlatziFakeStore",
            dependencies: [
                "Endpoints",
                "NetworkManager",
                .product(name: "SwiftFP", package: "SwiftFP")
            ]
        ),
        .target(name: "Endpoints"),
        .target(
            name: "NetworkManager",
            dependencies: [
                .product(name: "SwiftFP", package: "SwiftFP")
            ]
        ),
        .testTarget(
            name: "PlatziFakeStoreTests",
            dependencies: [
                "PlatziFakeStore",
                "Endpoints",
                "NetworkManager"
            ]
        ),
    ]
)
