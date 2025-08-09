// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Momentum",
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
        // Add external dependencies here if needed
    ],
    targets: [
        // Core module - Data models and shared utilities
        .target(
            name: "MomentumCore",
            dependencies: []
        ),
        
        // Authentication module
        .target(
            name: "MomentumAuthentication",
            dependencies: ["MomentumCore"]
        ),
        
        // UI Components module
        .target(
            name: "MomentumUI",
            dependencies: ["MomentumCore"]
        ),
        
        // Features module - Main app features
        .target(
            name: "MomentumFeatures",
            dependencies: [
                "MomentumCore",
                "MomentumAuthentication",
                "MomentumUI"
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