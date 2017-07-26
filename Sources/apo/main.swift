import Foundation
import ApodidaeCore
import CommandLineKit
import Rainbow

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

do {
    try Config.initializeIfNecessary()
} catch {
    print("There was an error creating the config file: \(error)".red)
    exit(1)
}

// Implicitly unwrapped since the compiler can't see the exit(1) in the catch block
let config: Config!
do {
    config = try Config.read()
} catch {
    print("There was an error reading the config file: \(error)\n".red)
    print("Delete it to have it recreated with default values on the next run.".red)
    exit(1)
}

switch command {
case .search(let query):
    config.printLIOWarningIfNecessary()

//    let semaphore = DispatchSemaphore(value: 0)
    Core.searchAll(query: query, librariesIOApiKey: config.lioAPIKey, isVerbose: verbosity.wasSet).then { packages in
        print("Found \(packages.count) package(s).\n")
        packages.forEach { print($0.cliRepresentation) }
//        semaphore.signal()
    }.catch { error in
        print("Encountered the following error: \(error)")
        exit(1)
    }
//    semaphore.wait()
    // Am I blocking the execution of the search with `semaphore.wait()`?!
    RunLoop.main.run(until: Date() + 4)
case .info(let package):
    if verbosity.wasSet { print("Getting info for \(package)...") }
default:
    print("This command is not yet supported.".yellow)
}
