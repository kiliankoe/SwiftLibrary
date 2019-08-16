// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftLibrary",
    products: [
        .library(
            name: "SwiftLibrary",
            targets: ["SwiftLibrary"]),
        .executable(
            name: "swift-library",
            targets: ["swift-library"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftLibrary",
            dependencies: []),
        .target(
            name: "swift-library",
            dependencies: ["SwiftLibrary"]),
        .testTarget(
            name: "SwiftLibraryTests",
            dependencies: ["SwiftLibrary"]),
    ]
)
