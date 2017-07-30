import Foundation
import Rainbow

public struct Repository: Decodable {
    public let nameWithOwner: String
    public let description: String?
    public let url: URL
    public let isFork: Bool
    public let parent: String?
    public let isPrivate: Bool
    public let pushedAt: Date
    public let license: String?
    public let openIssues: Int
    public let stargazers: Int
    public let tags: [Tag]
    public let hasPackageManifest: Bool

    private enum CodingKeys: String, CodingKey {
        case nameWithOwner
        case description
        case url
        case isFork
        case parent
        case isPrivate
        case pushedAt
        case license
        case openIssues
        case stargazers
        case tags
        case packageManifest
    }

    private enum NodeKeys: String, CodingKey {
        case node
    }

    private enum EdgesKeys: String, CodingKey {
        case edges
    }

    private enum TotalCountContainer: String, CodingKey {
        case totalCount
    }

    private enum PackageManifestContainer: String, CodingKey {
        case abbreviatedOid
    }

    public init(from decoder: Decoder) throws {
        let nodeContainer = try decoder.container(keyedBy: NodeKeys.self)
        let container = try nodeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
        self.nameWithOwner = try container.decode(String.self, forKey: .nameWithOwner)
        self.description = try container.decode(String?.self, forKey: .description)
        self.url = try container.decode(URL.self, forKey: .url)
        self.isFork = try container.decode(Bool.self, forKey: .isFork)
        self.parent = try container.decode(String?.self, forKey: .parent)
        self.isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        self.pushedAt = try container.decode(Date.self, forKey: .pushedAt)
        self.license = try container.decode(String?.self, forKey: .license)

        let openIssuesContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .openIssues)
        self.openIssues = try openIssuesContainer.decode(Int.self, forKey: .totalCount)

        let stargazersContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .stargazers)
        self.stargazers = try stargazersContainer.decode(Int.self, forKey: .totalCount)

        let tagsEdgesContainer = try container.nestedContainer(keyedBy: EdgesKeys.self, forKey: .tags)
        self.tags = try tagsEdgesContainer.decode([Tag].self, forKey: .edges)

        let packageManifestContainer = try? container.nestedContainer(keyedBy: PackageManifestContainer.self, forKey: .packageManifest)
        if let _ = packageManifestContainer {
            self.hasPackageManifest = true
        } else {
            self.hasPackageManifest = false
        }
    }

    public var latestVersion: String? {
        return tags.last?.name
    }

    public var shortCliRepresentation: String {
        var output = """
        - \(nameWithOwner.bold) \(latestVersion ?? "")
          \(url.absoluteString.italic)
        """
        if let description = self.description, !description.isEmpty {
            output += "\n  \(description)"
        }
        return output
    }

    public var longCliRepresentation: String {
        let versions = self.tags
            .map { $0.name }
            .reversed()
            .joined(separator: ", ")
        return """
        \(nameWithOwner.bold) \(latestVersion ?? "")
        \(url.absoluteString.underline)
        \(description ?? "No description available".italic)

        \(stargazers) stargazers
        \(license ?? "No license found")

        Last updated: \(pushedAt)
        Last versions: \(versions)
        """
    }

    public struct Tag: Decodable {
        let name: String

        private enum NodeKeys: String, CodingKey {
            case node
        }

        private enum CodingKeys: String, CodingKey {
            case name
        }

        public init(from decoder: Decoder) throws {
            let nodeContainer = try decoder.container(keyedBy: NodeKeys.self)
            let container = try nodeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
            self.name = try container.decode(String.self, forKey: .name)
        }
    }
}
