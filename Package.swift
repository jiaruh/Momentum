// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Momentum",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "MomentumCore", targets: ["MomentumCore"]),
        .library(name: "MomentumAuthentication", targets: ["MomentumAuthentication"]),
        .library(name: "MomentumUI", targets: ["MomentumUI"]),
        .library(name: "MomentumFeatures", targets: ["MomentumFeatures"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        // Core module - Data models and shared utilities
        .target(
            name: "MomentumCore",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Authentication module
        .target(
            name: "MomentumAuthentication",
            dependencies: ["MomentumCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // UI Components module
        .target(
            name: "MomentumUI",
            dependencies: ["MomentumCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Features module - Main app features
        .target(
            name: "MomentumFeatures",
            dependencies: [
                "MomentumCore",
                "MomentumAuthentication",
                "MomentumUI"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        
        // Tests
        .testTarget(
            name: "MomentumCoreTests",
            dependencies: ["MomentumCore"]
        ),
        .testTarget(
            name: "MomentumAuthenticationTests",
            dependencies: ["MomentumAuthentication"]
        ),
        .testTarget(
            name: "MomentumUITests",
            dependencies: ["MomentumUI"]
        ),
        .testTarget(
            name: "MomentumFeaturesTests",
            dependencies: ["MomentumFeatures"]
        )
    ]
)