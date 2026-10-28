// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraceAppsLibraryMac",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "GraceAppsLibraryMac",
            targets: ["GraceAppsLibraryMac"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GraceAppsLibraryMac",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "GraceAppsLibraryMacTests",
            dependencies: ["GraceAppsLibraryMac"]),
    ]
)
