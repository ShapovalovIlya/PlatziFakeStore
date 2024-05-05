// swift-tools-version: 5.7.1
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
        .library(name: "AsyncImageView", targets: ["AsyncImageView"])
    ],
    dependencies: [
        Dependencies.SwiftFP.package
    ],
    targets: [
        .target(
            name: "Validator",
            dependencies: [
                Dependencies.SwiftFP.product
            ]
        ),
        .target(
            name: "Endpoints",
            dependencies: [
                Dependencies.SwiftFP.product
            ]
        ),
        .target(
            name: "Request",
            dependencies: [
                Dependencies.SwiftFP.product
            ]
        ),
        .target(
            name: "AsyncImageView",
            dependencies: [
                Dependencies.SwiftFP.product
            ]
        ),
        .target(
            name: "PlatziFakeStore",
            dependencies: [
                "Validator",
                "Request",
                "Endpoints",
                "NetworkManager",
                Dependencies.SwiftFP.product
            ]
        ),
        .target(
            name: "NetworkManager",
            dependencies: [
                Dependencies.SwiftFP.product
            ]
        ),
        .testTarget(
            name: "PlatziFakeStoreTests",
            dependencies: [
                "PlatziFakeStore",
                "Endpoints",
                "NetworkManager",
                "Request",
                "Validator"
            ]
        ),
    ]
)

fileprivate enum Dependencies {
    case SwiftFP
    
    var package: Package.Dependency {
        switch self {
        case .SwiftFP: return .package(url: "https://github.com/ShapovalovIlya/SwiftFP.git", branch: "main")
        }
    }
    
    var product: Target.Dependency {
        switch self {
        case .SwiftFP: return .product(name: "SwiftFP", package: "SwiftFP")
        }
    }
}
