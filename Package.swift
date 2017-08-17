// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "apodidae",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jatoben/CommandLine", from: "3.0.0-pre1"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "2.0.1"),
        .package(url: "https://github.com/mxcl/PromiseKit", .branch("swift4-beta1")),
        .package(url: "https://github.com/JohnSundell/Files", from: "1.10.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "1.1.0"),
        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.3.3"),
        .package(url: "https://github.com/IBM-Swift/BlueSignals", from: "0.9.48"),
        .package(url: "https://github.com/sharplet/Regex", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ApodidaeCore",
            dependencies: ["PromiseKit", "Files", "Rainbow", "Regex", "CLISpinner", "ShellOut"]),
        .target(
            name: "swift-catalog",
            dependencies: ["ApodidaeCore", "CommandLine", "CLISpinner", "Signals"]),
        .testTarget(
            name: "ApodidaeTests",
            dependencies: ["ApodidaeCore"]),
    ]
)
