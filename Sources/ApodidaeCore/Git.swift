import Foundation
import Files
import ShellOut

public enum Git {
    public enum Error: Swift.Error {
        case notARepo
    }

    public static func uncommitedChanges(in dir: Folder = Folder.current) throws -> Bool {
        let result = try shellOut(to: "git", arguments: ["status -s"], at: dir.path)
        guard !result.contains("Not a git repository") else { throw Error.notARepo }
        return !result.isEmpty
    }
}

extension Git.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notARepo: return "Not a git repository (or any of the parent directories)"
        }
    }
}
