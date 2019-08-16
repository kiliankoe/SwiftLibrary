import Foundation

public struct PackageData: Decodable {
    public let id: Int
    public let url: URL
    public let host: String
    public let repositoryIdentifier: String
    public let name: String
    public let description: String
    public let versions: Versions
    public let releasedAgo: String
    public let swiftVersions: String
    public let license: String?
    public let supportedMacosVersion: String?
    public let supportedIosVersion: String?
    public let supportedWatchosVersion: String?
    public let supportedTvosVersion: String?
    public let libraryCount: Int
    public let executableCount: Int
    public let stargazers: Int
    public let watchers: Int
    public let searchScore: Int
    public let updatedAt: String // FIXME
}

extension PackageData {
    public struct Versions: Decodable {
        public let latest: String
        public let latest_stable: String?
    }
}
