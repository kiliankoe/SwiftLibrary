import Foundation
import SwiftLibrary

let args = Array(CommandLine.arguments.dropFirst())
if args.first?.contains("help") ?? false {
    print(Command.exampleUsage)
    exit(0)
}

guard let command = Command(from: args) else {
    print("Unrecognized command '\(args.joined(separator: " "))'")
    print("See --help for example usage.")
    exit(1)
}

switch command {
case .search(let query):
    let packages = allPackages(query: query)
    guard !packages.isEmpty else {
        print("No packages matching query found.")
        exit(0)
    }
    for package in packages {
        print(package.shortDescription)
        usleep(15_000) // The short delay helps the eye follow the results output.
    }
case .info(let input):
    guard let package = firstPackage(query: input) else {
        print("No package matching query found.")
        exit(1)
    }
    print(package.longDescription)
case .home(let input):
    guard let package = firstPackage(query: input) else {
        print("No package matching query found.")
        exit(1)
    }
    run(cmd: "/usr/bin/open", args: [package.url.absoluteString])
case .add(let input):
    guard let package = firstPackage(query: input.package) else {
        print("No package matching query found.")
        exit(1)
    }
    let dependencyString = ".package(url: \"\(package.url.absoluteString)\", \(input.requirement?.packageString ?? ".branch(\"master\")"))"
    #if os(macOS)
    addToPasteboard(string: dependencyString)
    print("Your clipboard has been updated, just add it to your package manifest.")
    #else
    print("Copy the following and add it to your package manifest.")
    print(dependencyString)
    #endif
}
