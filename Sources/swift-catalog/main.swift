import Foundation
import ApodidaeCore
import CommandLineKit
import Rainbow
import ShellOut
import CLISpinner
import Signals
import Files

let cli = CommandLine()

cli.formatOutput = { s, type in // swiftlint:disable:this identifier_name
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
let noResolveFlag = BoolOption(longFlag: "no-resolve", helpMessage: "Don't run `swift package resolve` after adding packages.")

cli.addOptions(help, version, verbosity, searchForksFlag, noResolveFlag)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(1)
}

guard !help.wasSet else {
    print(Command.exampleUsage)
    print()
    cli.printUsage()
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

Signals.trap(signal: .int) { _ in
    spinner.unhideCursor()
    exit(1)
}

switch command {
case .search(let query):
    GitHub.repos(with: query, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet).then { response in
        let (repos, meta) = response

        let packageQuantityStr = repos.count > 1 ? "packages" : "package"
        spinner.succeed(text: "Found \(repos.count) \(packageQuantityStr)")

        if verbosity.wasSet { print(meta.cliRepresentation) }

        repos.forEach { print($0.shortCliRepresentation); usleep(15_000) } // The short delay helps the eye follow the results output.
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .info(let input):
    GitHub.firstRepoIncludingRefs(with: input, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, spinner: spinner).then { response in
        let (repo, meta) = response

        spinner.stopAndClear()

        if verbosity.wasSet { print(meta.cliRepresentation) }

        print(repo.longCliRepresentation)
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .home(let input):
    GitHub.firstRepo(with: input, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet).then { response in
        let (repo, meta) = response

        spinner.stopAndClear()

        if verbosity.wasSet { print(meta.cliRepresentation) }

        try shellOut(to: "open \(repo.url.absoluteString)")
        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
case .add(let input):
    GitHub.firstRepoIncludingRefs(with: input.package, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet, spinner: spinner).then { response in
        let (repo, meta) = response

        spinner.stopAndClear()

        if verbosity.wasSet { print(meta.cliRepresentation) }

        do {
            if try Git.uncommitedChanges() {
                print("There are uncommitted changes present in your working directory.")
                guard confirm("Do you want to continue anyways?", default: true) else {
                    print("Exiting without changes.")
                    exit(0)
                }
            }
        } catch {
            print("It appears you're not inside a git repository. Please be very sure about what you're doing.")
            guard confirm("Continue?", default: false) else {
                print("Exiting without changes.")
                exit(0)
            }
        }

        let requirement: Requirement
        if let req = input.requirement {
            requirement = req
        } else {
            if let latestVersion = repo.latestVersion {
                requirement = .tag(latestVersion)
            } else {
                requirement = repo.heads.contains("master") ? .branch("master") : .branch(repo.heads.first!) // this will crash if the repo contains no branches... Can that happen?
            }
        }

        do {
            try Manifest.insertIntoLocalManifest(package: repo, requirement: requirement)
            print("Added \(repo.nameWithOwner.lightCyan) to your package manifest.")
        } catch {
            print("An error occurred editing your package manifest: \(error.localizedDescription.red)")
            let swiftVersion = try SwiftVersion.readFromLocalPackage()
            let packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: requirement)
            try shellOut(to: "echo '\(packageString)' | pbcopy")
            print("The following has been copied to your clipboard, please paste it into your manifest manually.")
            print(packageString)
            exit(0)
        }

        guard !noResolveFlag.wasSet else { exit(0) }

        let resolveSpinner = Spinner(pattern: .dots, text: "Resolving dependencies...", color: .lightCyan)
        resolveSpinner.start()

        do {
            try shellOut(to: "swift", arguments: ["package", "resolve"])
            resolveSpinner.succeed(text: "Successfully resolved dependencies.")
        } catch {
            if let error = error as? ShellOutError {
                resolveSpinner.fail(text: "\(error.message)")
            } else {
                resolveSpinner.fail(text: "\(error.localizedDescription)") // This case should probably be impossible...
            }
            exit(1)
        }

        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
}
RunLoop.main.run(until: Date.distantFuture)
