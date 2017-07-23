import Foundation

public enum Command {
    case search(query: String)
    case info(package: String)
    case add(package: String)
    case remove(package: String)
    case list

    public static var all: String {
        return "search <query>, info <package_name>, add <package_name>, remove <package_name>, list"
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
        case "add", "a":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .add(package: package)
        case "remove", "r":
            guard strings.count == 2 else { return nil }
            let package = strings[1]
            self = .remove(package: package)
        case "list", "l":
            self = .list
        default:
            return nil
        }
    }
}
