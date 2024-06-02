// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrassBand",
    platforms: [.macOS(.v15), .iOS(.v18), .macCatalyst(.v18)],
    products: [
        .library(
            name: "BrassBand",
            targets: ["BrassBand"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics.git", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.2"))
    ],
    targets: [
        .target(
            name: "BrassBandCpp"
        ),
        .target(
            name: "BrassBand",
            dependencies: [
                "BrassBandCpp",
                .product(name: "Collections", package: "swift-collections")
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .enableUpcomingFeature("ExistentialAny")
            ],
            linkerSettings: [
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit"),
            ]
        ),
        .testTarget(
            name: "BrassBandTests",
            dependencies: [
                "BrassBand",
                .product(name: "Numerics", package: "swift-numerics")
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]),
    ],
    cLanguageStandard: .gnu2x,
    cxxLanguageStandard: .gnucxx2b
)
