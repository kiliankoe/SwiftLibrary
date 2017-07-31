import Foundation

public enum Command {
    case search(String)
    case info(String)
    case home(String)
    case add(package: String, requirement: Requirement?)

    public static var exampleUsage: String {
        return """
        Commands:
          swift catalog search <query>
              Search for packages matching query.
          swift catalog info <package_name>
              Get additional info to a package.
          swift catalog home <package_name>
              Open the homepage of a package in your browser.
          swift catalog add <package_name>
              Add the given package to your Package.swift's dependencies.
        """
    }

    public init?(from strings: [String]) {
        guard
            strings.count > 0,
            let command = strings.first
        else { return nil }

        let query = strings[1...].joined(separator: " ")
        guard !query.isEmpty else { return nil }

        switch command.lowercased() {
        case "search", "s": self = .search(query)
        case "info", "i": self = .info(query)
        case "home", "h": self = .home(query)
        case "add", "a", "+":
            // TODO: It would probably be easier to tackle this via regex instead of splitting strings...
            guard query.contains("@") else {
                // easy case first...
                self = .add(package: query, requirement: nil)
                return
            }

            let queryComponents = query
                .trimmingCharacters(in: .whitespaces)
                .split(separator: "@", maxSplits: 1)

            guard
                queryComponents.count == 2,
                let packageName = queryComponents.first,
                let requirement = queryComponents.last
            else { return nil }

            guard requirement.contains(":") else {
                // no specifically named requirement means it's a tag
                self = .add(package: String(packageName), requirement: .tag(String(requirement)))
                return
            }

            // Continuing here if the add command includes a *specific* named requirement, e.g. @tag:0.1.0 or @branch:master
            let specificComponents = requirement.split(separator: ":", maxSplits: 1)
            guard
                let specificRequirementName = specificComponents.first,
                let specificRequirementValue = specificComponents.last
            else { return nil }

            switch specificRequirementName {
            case "tag", "version":
                self = .add(package: String(packageName), requirement: .tag(String(specificRequirementValue)))
            case "branch":
                self = .add(package: String(packageName), requirement: .branch(String(specificRequirementValue)))
            case "revision", "commit":
                self = .add(package: String(packageName), requirement: .revision(String(specificRequirementValue)))
            default: return nil // It would probably make sense to start returning actual errors at some point...
            }
        default:
            return nil
        }
    }
}

extension Command: Equatable {
    public static func ==(lhs: Command, rhs: Command) -> Bool {
        switch (lhs, rhs) {
        case (.search(let lhss), .search(let rhss)): return lhss == rhss
        case (.info(let lhsi), .info(let rhsi)): return lhsi == rhsi
        case (.home(let lhsh), .home(let rhsh)): return lhsh == rhsh
        case (.add(let lhsp, let lhsr), .add(let rhsp, let rhsr)):
            return lhsp == rhsp && lhsr == rhsr
        default: return false
        }
    }
}
