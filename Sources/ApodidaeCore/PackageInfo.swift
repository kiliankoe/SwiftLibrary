import Foundation

public struct PackageInfo: Decodable {
    public let id: Int
    public let name: String
    public let author: String
    public let description: String
    public let githubURL: URL
    public let published: String
    public let license: String
    public let version: String
    public let swiftVersion: String
    public let stars: Int // this can also be a string
    public let dependencies: [Dependency]
    public let versions: [Version]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case author = "publisher"
        case description
        case githubURL = "ghUrl"
        case published
        case license
        case version
        case swiftVersion = "swift_version"
        case stars
        case dependencies
        case versions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.author = try container.decode(String.self, forKey: .author)
        self.description = try container.decode(String.self, forKey: .description)
        self.githubURL = try container.decode(URL.self, forKey: .githubURL)
        self.published = try container.decode(String.self, forKey: .published)
        self.license = try container.decode(String.self, forKey: .license)
        self.version = try container.decode(String.self, forKey: .version)
        self.swiftVersion = try container.decode(String.self, forKey: .swiftVersion)
        do {
            self.stars = try container.decode(Int.self, forKey: .stars)
        } catch {
            // Unfortunately stars can also come as "n/a" if no stars are recorded
            self.stars = 0
        }
        self.dependencies = try container.decode([Dependency].self, forKey: .dependencies)
        self.versions = try container.decode([Version].self, forKey: .versions)
    }

    public var cliRepresentation: String {
        let versions = self.versions.map { $0.tag }.joined(separator: " ")
        let dependencies = self.dependencies.count > 0 ? self.dependencies.map { $0.name }.joined(separator: "\n  ") : " None"

        return """
        \((author + "/" + name).bold) \(version)
        \((githubURL.absoluteString).underline)
        \(description)

        \(stars) stargazers
        \(license)
        Supports Swift \(swiftVersion)

        Last published: \(published)
        Versions:
        \(versions)

        Dependencies:
          \(dependencies)
        """
    }
}

extension PackageInfo {
    public struct Dependency: Decodable {
        public let name: String
        public let version: String // majorVersion: 1, minor: 2 (wow...)

        private enum CodingKeys: String, CodingKey {
            case name = "dependency_full_name"
            case version = "dependency_version"
        }
    }

    public struct Version: Decodable {
        public let tag: String
    }
}
