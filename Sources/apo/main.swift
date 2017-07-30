import Foundation
import ApodidaeCore
import CommandLineKit
import Rainbow
import ShellOut

let cli = CommandLine()

cli.formatOutput = { s, type in
    let str: String
    switch type {
    case .error:
        str = s.red
    default:
        str = s
    }

    return cli.defaultFormat(s: str, type: type)
}

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help message.")
let version = BoolOption(longFlag: "version", helpMessage: "Output the version of apodidae.")
let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Print verbose messages.")

let swiftVersionFlag = IntOption(longFlag: "swiftversion", helpMessage: "Manually specify a swift version for the generated dependency string on `apo add`.")

cli.addOptions(help, version, verbosity, swiftVersionFlag)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(1)
}

guard !help.wasSet else {
    cli.printUsage()
    print()
    print(Command.exampleUsage)
    exit(0)
}

guard !version.wasSet else {
    print(APODIDAE_VERSION)
    exit(0)
}

guard cli.unparsedArguments.count != 0 else {
    print("No command given".yellow)
    print("See --help for example usage.")
    exit(1)
}

guard let command = Command(from: cli.unparsedArguments) else {
    print("Unrecognized command '\(cli.unparsedArguments.joined(separator: " "))'".red)
    print("See --help for example usage.")
    exit(1)
}

let githubAuthToken = ProcessInfo.processInfo.environment["GITHUB_AUTHKEY"]!

switch command {
case .search(let query):
    GitHub.repos(with: query, authToken: githubAuthToken, isVerbose: verbosity.wasSet).then { response in
        if let error = response.errors?.first {
            throw error
        }
        guard let repos = response.data?.repositories else {
            print("No packages found".yellow)
            exit(0)
        }
        repos.forEach { print($0.shortCliRepresentation) }
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .info(let package):
    GitHub.repos(with: package, authToken: githubAuthToken, isVerbose: verbosity.wasSet).then { response in
        if let error = response.errors?.first {
            throw error
        }
        guard let repo = response.data?.repositories.first else {
            print("No such package found".yellow)
            exit(0)
        }
        print(repo.longCliRepresentation)
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .home(let package):
    GitHub.repos(with: package, authToken: githubAuthToken, isVerbose: verbosity.wasSet).then { response in
        if let error = response.errors?.first {
            throw error
        }
        guard let repo = response.data?.repositories.first else {
            print("No such package found".yellow)
            exit(0)
        }
        try shellOut(to: "open \(repo.url.absoluteString)")
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .add(let package):
    GitHub.repos(with: package, authToken: githubAuthToken, isVerbose: verbosity.wasSet).then { response in
        if let error = response.errors?.first {
            throw error
        }
        guard let repo = response.data?.repositories.first else {
            print("No such package found".yellow)
            exit(0)
        }
        let swiftVersion: SwiftVersion
        if swiftVersionFlag.wasSet, let version = SwiftVersion(from: swiftVersionFlag.value ?? 0) {
            swiftVersion = version
        } else {
            swiftVersion = SwiftVersion.readFromLocalPackage()
        }

        let packageString: String
        if let latestVersion = repo.tags.last?.name {
            packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: .version(latestVersion))
        } else {
            packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: .branch("master"))
        }

        try shellOut(to: "echo '\(packageString)' | pbcopy")
        print("The following has been copied to your clipboard for convenience, just paste it into your package manifests's dependencies.")
        print()
        print(packageString.green)
        print()
        print("Please bear in mind that apodidae can not be sure if it is actually possible to include this package in your project.")
        print("It can only be safely assumed that this is a package written in Swift that contains a file named 'Package.swift'. It")
        print("might also be an executable project instead of a library.")
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
}
