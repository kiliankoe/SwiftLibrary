import Foundation

public enum Command {
    case search(String)
    case info(String)
    case home(String)
    case add(String)

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
        guard strings.count > 0, let first = strings.first else { return nil }
        switch first.lowercased() {
        case "search", "s":
            guard strings.count >= 2 else { return nil }
            let package = strings.dropFirst().joined(separator: " ")
            self = .search(package)
        case "info", "i":
            guard strings.count >= 2 else { return nil }
            let package = strings.dropFirst().joined(separator: " ")
            self = .info(package)
        case "home", "h":
            guard strings.count >= 2 else { return nil }
            let package = strings.dropFirst().joined(separator: " ")
            self = .home(package)
        case "add", "a", "+":
            guard strings.count >= 2 else { return nil }
            let package = strings.dropFirst().joined(separator: " ")
            self = .add(package)
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
