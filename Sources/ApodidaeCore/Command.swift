import Foundation

public enum Command {
    case search(String)
    case info(String)
    case home(String)
    case add(String)

    public static var exampleUsage: String {
        return """
        Commands:
          apo search <query>
              Search for the query on all available sources.
          apo info <package_name>
              Get additional info to a package.
          apo home <package_name>
              Open the homepage of a package in your browser.
          apo add <package_name>
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
        case "add", "a":
            guard strings.count >= 2 else { return nil }
            let package = strings.dropFirst().joined(separator: " ")
            self = .add(package)
        default:
            return nil
        }
    }
}
