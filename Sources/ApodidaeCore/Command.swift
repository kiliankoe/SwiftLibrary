import Foundation

public enum Command {
    case search(query: String)
    case info(package: String)
    case home(package: String)
    case add(package: String)
    case remove(package: String)
    case submit
    case list

    public static var exampleUsage: String {
        return """
        Example usage:
            apo search <query>
            apo info <package_name>
            apo home <package_name>
            apo add <package_name>
            apo remove <package_name>
            apo submit
            apo list
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
        case "remove", "r":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .remove(package: package)
        case "submit":
            self = .submit
        case "list", "l":
            self = .list
        default:
            return nil
        }
    }
}
