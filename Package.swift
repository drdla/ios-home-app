// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HomeDashboard",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "HomeDashboardCore", targets: ["HomeDashboardCore"])
    ],
    targets: [
        .target(
            name: "HomeDashboardCore",
            path: "Sources/HomeDashboardCore"
        ),
        .testTarget(
            name: "HomeDashboardCoreTests",
            dependencies: ["HomeDashboardCore"],
            path: "Tests/HomeDashboardCoreTests"
        )
    ]
)
