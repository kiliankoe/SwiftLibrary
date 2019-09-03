import Foundation

public struct PackageData: Decodable {
    public let id: Int
    public let url: URL
    public let host: String
    public let repositoryIdentifier: String
    public let name: String
    public let description: String?
    public let license: String?
    public let stars: Int
    public let updatedAt: String // FIXME

    public let versions: [Version]

    public var latest: Version {
        guard let first = self.versions.first else {
            fatalError("No version found, according to Dave this shouldn't happen :P")
        }
        return first
    }

    public var latestRelease: Version? {
        self.versions.first { $0.kind == .tag }
    }
}

extension PackageData {
    public struct Version: Decodable {
        public let name: String
        public let kind: Kind
        public let releasedAgo: String?
        public let swiftVersions: String
        public let supportedMacosVersion: String?
        public let supportedIosVersion: String?
        public let supportedWatchosVersion: String?
        public let supportedTvosVersion: String?
        public let libraryCount: Int
        public let executableCount: Int

        public enum Kind: String, Decodable {
            case branch, tag
        }
    }
}

extension PackageData {
    public var shortDescription: String {
        var output = """
        - \(repositoryIdentifier)
          \(url.absoluteString)
        """
        if let description = self.description, !description.isEmpty {
            output += "\n  \(description)"
        }
        return output
    }

    public var longDescription: String {
        let libraryString = latest.libraryCount == 1 ? "library" : "libraries"
        let executableString = latest.executableCount == 1 ? "executable" : "executables"

        var output = """
        \(repositoryIdentifier) \(latest.name) \(latestRelease?.name ?? "")
        \(description ?? "No description available")

        \(stars) stargazers

        Licensed under \(license ?? "n/a").
        Supports Swift \(latest.swiftVersions).
        Last released \(latestRelease?.releasedAgo ?? "n/a") ago.
        Contains \(latest.libraryCount) \(libraryString).
        Contains \(latest.executableCount) \(executableString).
        
        """

        if let macOS = latest.supportedMacosVersion {
            output += "\nSupports macOS \(macOS)"
        }
        if let iOS = latest.supportedIosVersion {
            output += "\nSupports iOS \(iOS)"
        }
        if let tvOS = latest.supportedTvosVersion {
            output += "\nSupports tvOS \(tvOS)"
        }
        if let watchOS = latest.supportedWatchosVersion {
            output += "\nSupports watchOS \(watchOS)"
        }
        return output
    }
}
