import Foundation
import Files
import ShellOut

public enum Git {
    public enum Error: Swift.Error {
        case notARepo
        case remoteNotFound
    }

    public static func uncommitedChanges(in dir: Folder = Folder.current) throws -> Bool {
        let result = try shellOut(to: "git", arguments: ["status -s"], at: dir.path)
        guard !result.contains("Not a git repository") else { throw Error.notARepo }
        return !result.isEmpty
    }

    public static func ls(remote: String) throws -> (heads: [String], tags: [String]) {
        let result = try shellOut(to: "git", arguments: ["ls-remote", "--heads", "--tags", remote])
        guard !result.contains("remote: Not Found") else { throw Error.remoteNotFound }
        let refs = result
            .split(separator: "\n")
            .map { $0.split(separator: "\t") }
            .flatMap { $0.last }
            .map(String.init)

        let heads = refs
            .filter { $0.hasPrefix("refs/heads") }
            .map { $0.replacingOccurrences(of: "refs/heads/", with: "") }

        let tags = refs
            .filter { $0.hasPrefix("refs/tags") }
            .filter { !$0.contains("^{") } // filter github releases (I think these are releases)
            .map { $0.replacingOccurrences(of: "refs/tags/", with: "") }

        return (heads, tags)
    }
}

extension Git.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notARepo: return "Not a git repository (or any of the parent directories)"
        case .remoteNotFound: return "Remote not found"
        }
    }
}
