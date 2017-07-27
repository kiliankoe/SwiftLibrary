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

let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Display this help message")
let version = BoolOption(longFlag: "version", helpMessage: "Output the version of apodidae")
let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Print verbose messages")

cli.addOptions(help, version, verbosity)

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
    print("0.1.0") // TODO: Pull this from elsewhere
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

switch command {
case .search(let query):
    PackageCatalog.search(query: query, isVerbose: verbosity.wasSet).then { packages in
        packages.forEach { print($0.cliRepresentation) }
        exit(0)
    }.catch { error in
        print("Encountered the following error: \(error)".red)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .info(let package):
    PackageCatalog.getInfo(for: package, isVerbose: verbosity.wasSet).then { packageInfo in
        print(packageInfo.cliRepresentation)
        exit(0)
    }.catch { error in
        print(error.localizedDescription)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
case .home(let package):
    PackageCatalog.getInfo(for: package, isVerbose: verbosity.wasSet).then { packageInfo in
        try shellOut(to: "open \(packageInfo.githubURL.absoluteString)")
        exit(0)
    }.catch { error in
        print("Encountered the following error: \(error)".red)
        exit(1)
    }
    RunLoop.main.run(until: Date.distantFuture)
default:
    print("This command is not yet supported.".yellow)
}
