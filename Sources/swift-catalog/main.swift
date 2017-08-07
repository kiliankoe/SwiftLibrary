import Foundation
import ApodidaeCore
import CommandLineKit
import Rainbow
import ShellOut
import CLISpinner
import Signals
import Files

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
    GitHub.firstRepo(with: input, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet).then { response in
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
    GitHub.firstRepo(with: input.package, accessToken: config.githubAccessToken, searchForks: searchForksFlag.wasSet).then { response in
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
            if let latestVersion = repo.tags.last?.name {
                requirement = .tag(latestVersion)
            } else {
                requirement = .branch("master")
            }
        }

        do {
            try Manifest.insertIntoLocalManifest(package: repo, requirement: requirement)
            print("Added \(repo.nameWithOwner.lightCyan) to your package manifest.")
        } catch {
            print("An error occurred editing your package manifest: \(error.localizedDescription)")
            let swiftVersion = try SwiftVersion.readFromLocalPackage()
            let packageString = try repo.dependencyRepresentation(for: swiftVersion, requirement: requirement)
            try shellOut(to: "echo '\(packageString)' | pbcopy")
            print("The following has been copied to your clipboard, please paste it into your manifest manually.")
            print(packageString)
        }

        exit(0)
    }.catch { error in
        spinner.fail(text: error.localizedDescription)
        exit(1)
    }
}
RunLoop.main.run(until: Date.distantFuture)
