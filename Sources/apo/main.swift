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
        // TODO: Handle error
        // TODO: Output some more response output if verbose, e.g. number of results, remaining API calls
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
    PackageCatalog.getInfoAfterSearch(for: package, isVerbose: verbosity.wasSet).then { packageInfo in
        try shellOut(to: "open \(packageInfo.githubURL.absoluteString)")
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .add(let package):
    PackageCatalog.getInfoAfterSearch(for: package, isVerbose: verbosity.wasSet).then { packageInfo in
        let swiftVersion: SwiftVersion
        if swiftVersionFlag.wasSet, let version = SwiftVersion(from: swiftVersionFlag.value ?? 0) {
            swiftVersion = version
        } else {
            swiftVersion = SwiftVersion.readFromLocalPackage()
        }

        let possiblePackageString: String?
        if let latestVersion = packageInfo.versions.first?.tag, latestVersion.lowercased() != "latest" {
            possiblePackageString = packageInfo.dependencyRepresentation(for: swiftVersion, requirement: .version(latestVersion))
        } else {
            possiblePackageString = packageInfo.dependencyRepresentation(for: swiftVersion, requirement: .branch("master"))
        }

        guard let packageString = possiblePackageString else {
            print("Could not generate a package string with this requirement for Swift 3.".red) // Currently only possible in that case.
            exit(1)
        }

        try! shellOut(to: "echo '\(packageString)' | pbcopy")
        print("The following has been copied to your clipboard. Go ahead and paste it into your Package.swift's dependencies.")
        print()
        print(packageString.green)
        print()
        print("Please bear in mind that apodidae can not know if it is actually possible to include this package in your project.")
        print("This is just \("some".italic) available package from packagecatalog.com including its last publicized version.")
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .submit(let package):
    let packageURL: URL
    if let package = package {
        if let url = URL(string: package), (url.scheme ?? "").contains("http") {
            packageURL = url
        } else {
            print("Packagecatalog.com expects a valid URL that's compatible with Swift Package Manager, e.g. 'https://www.github.com/foo/bar.git'.".yellow)
            exit(1)
        }
    } else {
        if let origin = try? shellOut(to: "git config remote.origin.url"), let url = URL(string: origin), (url.scheme ?? "").contains("http") {
            packageURL = url
        } else {
            print("Could not read remote URL from the current directory (only works for http(s) schemes). Please specify it manually.".red)
            exit(1)
        }
    }
    PackageCatalog.submit(url: packageURL, isVerbose: verbosity.wasSet).then { _ in
        print("Package successfully submitted to packagecatalog.com".green)
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
}
