// swift-tools-version:5.1

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
    dependencies: [
//        .package(url: "https://github.com/jatoben/CommandLine", from: "3.0.0-pre1"),
//        .package(url: "https://github.com/onevcat/Rainbow", from: "2.0.1"),
//        .package(url: "https://github.com/mxcl/PromiseKit", from: "5.0.0"),
//        .package(url: "https://github.com/JohnSundell/Files", from: "1.10.0"),
//        .package(url: "https://github.com/JohnSundell/ShellOut", from: "1.1.0"),
//        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.3.3"),
//        .package(url: "https://github.com/IBM-Swift/BlueSignals", from: "0.9.48"),
//        .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
    ],
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
