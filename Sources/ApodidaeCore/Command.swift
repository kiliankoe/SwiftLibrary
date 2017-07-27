import Foundation

public enum Command {
    case search(query: String)
    case info(package: String)
    case home(package: String)
    case add(package: String)
    case submit(package: String?)

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
          apo submit <optional: package_name>
              Submit the package in the current directory or a specified other one to packagecatalog.com.
        """
    }

    public init?(from strings: [String]) {
        guard strings.count > 0, let first = strings.first else { return nil }
        switch first.lowercased() {
        case "search", "s":
            guard strings.count >= 2 else { return nil }
            let query = strings.dropFirst().joined(separator: " ")
            self = .search(query: query)
        case "info", "i":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .info(package: package)
        case "home", "h":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .home(package: package)
        case "add", "a":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .add(package: package)
        case "submit":
            if strings.count == 2 {
                let package = strings[1]
                self = .submit(package: package)
            } else {
                self = .submit(package: nil)
            }
        default:
            return nil
        }
    }
}
