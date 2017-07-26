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

var config: Config? = nil
do {
    config = try Config.read()
} catch {
    print("There was an error reading the config file: \(error)".red)
    exit(1)
}

switch command {
case .search(let query):
    if verbosity.wasSet { print("Searching for \(query)...") }
case .info(let package):
    if verbosity.wasSet { print("Getting info for \(package)...") }
default:
    print("This command is not yet supported.".yellow)
}
