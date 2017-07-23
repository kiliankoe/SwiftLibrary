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
let verbosity = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Print verbose messages")

cli.addOptions(help, verbosity)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(1)
}

guard !help.value || cli.unparsedArguments.count == 0 else {
    cli.printUsage()
    exit(0)
}

guard let command = Command(from: cli.unparsedArguments) else {
    print("Unrecognized command".red)
    print("Currently supported are:\n\(Command.all)")
    exit(1)
}

switch command {
case .search(let query):
    print("Searching for \(query)...")
default:
    print("This command is not yet supported.".yellow)
}
