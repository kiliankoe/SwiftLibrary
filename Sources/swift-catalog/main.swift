import Foundation
import ApodidaeCore
import CommandLineKit
import Rainbow
import ShellOut
import CLISpinner
import Signals

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

let searchForksFlag = BoolOption(shortFlag: "f", longFlag: "search-forks", helpMessage: "Search for forks matching the query as well.")
let swiftVersionFlag = IntOption(longFlag: "swiftversion", helpMessage: "Manually specify a swift version for the generated dependency string on `swift catalog add`.")

cli.addOptions(help, version, verbosity, searchForksFlag, swiftVersionFlag)

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

try Config.initializeIfNecessary()
let config: Config
do {
    config = try Config.read()
} catch let error {
    print("There was an error reading your config at \(Config.configFilePath.italic).")
    print("You can either fix it manually or delete the file to have it recreated on the next run.")
    print()
    print("\(error)".red)
    exit(1)
}
guard config.githubAccessToken != Config.tokenPlaceholder else {
    print(Config.tokenWarning)
    exit(0)
}

let spinner = Spinner(pattern: .dots, text: "Searching on GitHub...", color: .lightCyan)
spinner.start()

Signals.trap(signal: .int) { signal in
    spinner.unhideCursor()
    exit(1)
}

switch command {
case .search(let query):
    GitHub.repos(with: query, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, isVerbose: verbosity.wasSet).then { repos in
        let packageQuantityStr = repos.count > 1 ? "packages" : "package"
        spinner.succeed(text: "Found \(repos.count) \(packageQuantityStr)")
        print()
        repos.forEach { print($0.shortCliRepresentation); usleep(15_000) }
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .info(let input):
    GitHub.firstRepo(with: input, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, isVerbose: verbosity.wasSet).then { repo in
        spinner.stopAndClear()
        print(repo.longCliRepresentation)
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .home(let input):
    GitHub.firstRepo(with: input, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, isVerbose: verbosity.wasSet).then { repo in
        spinner.stopAndClear()
        try shellOut(to: "open \(repo.url.absoluteString)")
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .add(let input):
    GitHub.firstRepo(with: input.package, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, isVerbose: verbosity.wasSet).then { repo in
        spinner.stopAndClear()

        let swiftVersion: SwiftVersion
        if swiftVersionFlag.wasSet, let version = SwiftVersion(from: swiftVersionFlag.value ?? 0) {
            swiftVersion = version
        } else {
            swiftVersion = SwiftVersion.readFromLocalPackage()
        }

        let packageString: String
        if let requirement = input.requirement {
            packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: requirement)
        } else {
            if let latestVersion = repo.tags.last?.name {
                packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: .tag(latestVersion))
            } else {
                packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: .branch("master"))
            }
        }

        try shellOut(to: "echo '\(packageString)' | pbcopy")
        print("The following has been copied to your clipboard for convenience, just paste it into your Package.swift.")
        print()
        print(packageString.green)
        print()
        print("Please bear in mind that apodidae can not be sure if it is actually possible to include this package in your project.")
        print("It can only be safely assumed that this is a package written in Swift that contains a file named 'Package.swift'. It")
        print("might also be an executable project instead of a library.")
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
}
RunLoop.main.run(until: Date.distantFuture)
