import Foundation
import Regex
import Rainbow

public typealias Tag = String
public typealias Head = String

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
    public var tags: [Tag] = []
    public var heads: [Head] = []
    public let packageManifest: String?

    public var hasPackageManifest: Bool {
        if let _ = self.packageManifest {
            return true
        }
        return false
    }

    public var dependencies: [String] {
        guard let manifest = self.packageManifest else { return [] }
        let packageRegex = Regex("url: \"(\\S+)\",.+\\)")
        let githubRegex = Regex("https?:\\/\\/github.com\\/")
        let gitSuffixRegex = Regex(".git$")

        return packageRegex.allMatches(in: manifest)
            .flatMap { $0.captures.first ?? nil }
            .map { $0.replacingAll(matching: githubRegex, with: "") }
            .map { $0.replacingAll(matching: gitSuffixRegex, with: "") }
    }

    public var owner: String {
        return nameWithOwner.components(separatedBy: "/").first ?? ""
    }

    public var name: String {
        return nameWithOwner.components(separatedBy: "/").last ?? ""
    }

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
        case text
    }

    private enum ParentContainer: String, CodingKey {
        case nameWithOwner
    }

    public init(from decoder: Decoder) throws {
        let nodeContainer = try decoder.container(keyedBy: NodeKeys.self)
        let container = try nodeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
        self.nameWithOwner = try container.decode(String.self, forKey: .nameWithOwner)
        self.description = try container.decode(String?.self, forKey: .description)
        self.url = try container.decode(URL.self, forKey: .url)
        self.isFork = try container.decode(Bool.self, forKey: .isFork)

        let parentContainer = try? container.nestedContainer(keyedBy: ParentContainer.self, forKey: .parent)
        self.parent = try parentContainer?.decode(String?.self, forKey: .nameWithOwner)

        self.isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        self.pushedAt = try container.decode(Date.self, forKey: .pushedAt)
        self.license = try container.decode(String?.self, forKey: .license)

        let openIssuesContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .openIssues)
        self.openIssues = try openIssuesContainer.decode(Int.self, forKey: .totalCount)

        let stargazersContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .stargazers)
        self.stargazers = try stargazersContainer.decode(Int.self, forKey: .totalCount)

        let packageManifestContainer = try? container.nestedContainer(keyedBy: PackageManifestContainer.self, forKey: .packageManifest)
        if let packageManifestContainer = packageManifestContainer {
            self.packageManifest = try packageManifestContainer.decode(String.self, forKey: .text)
        } else {
            self.packageManifest = nil
        }
    }

    public var latestVersion: String? {
        return tags.first
    }

    public var shortCliRepresentation: String {
        let priv = isPrivate ? "private" : ""
        let fork = "Fork of \(parent ?? "unknown")".lightBlue
        var output = """
        - \(owner.bold.italic)/\(name.lightCyan.bold) \(priv.yellow)
          \(url.absoluteString.italic)
        """
        if isFork {
            output += "\n  \(fork)"
        }
        if let description = self.description, !description.isEmpty {
            output += "\n  \(description)"
        }
        return output
    }

    public var longCliRepresentation: String {
        let bound = self.tags.count >= 8 ? 8 : self.tags.count
        let versions = self.tags[..<bound]
            .joined(separator: ", ")
        let priv = isPrivate ? "private" : ""
        let fork = "Fork of \(parent ?? "unknown")".lightBlue

        let dependencies = self.dependencies.isEmpty ? "  None" : "  " + self.dependencies.joined(separator: "\n  ")

        var output = """
        \(owner.bold.italic)/\(name.lightCyan.bold) \(latestVersion ?? "unreleased".italic) \(priv.yellow)
        \(url.absoluteString.italic)\n
        """

        if isFork {
            output += """
            \(fork)\n
            """
        }

        output += """
        \(description ?? "No description available".italic)

        \(license ?? "No license found")
        
        \(stargazers) stargazers
        \(openIssues) open issues

        Last activity: \(pushedAt.iso)
        Last versions: \(versions)
        Branches: \(heads.joined(separator: ", "))

        Dependencies:
        \(dependencies)
        """

        return output
    }

    public enum DependencyRepresentationError: Error {
        case notRepresentableWithSwift3(Requirement)
        case tagNotAvailable
        case branchNotAvailable
    }

    public func dependencyRepresentation(for swiftVersion: SwiftVersion, requirement: Requirement) throws -> String {
        switch requirement {
        case .tag(let tag):
            guard self.tags.contains(tag) else { throw DependencyRepresentationError.tagNotAvailable }
        case .branch(let branch):
            guard self.heads.contains(branch) else { throw DependencyRepresentationError.branchNotAvailable }
        default: break
        }

        switch swiftVersion {
        case .v3:
            guard case .tag(let version) = requirement else { throw DependencyRepresentationError.notRepresentableWithSwift3(requirement) }
            let versionComponents = version.components(separatedBy: ".")
            return ".Package(url: \"\(self.url)\", majorVersion: \(versionComponents[0]), minor: \(versionComponents[1])),"
        case .v4:
            return ".package(url: \"\(self.url)\", \(requirement.packageString)),"
        }
    }
}

extension Repository.DependencyRepresentationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notRepresentableWithSwift3(let requirement):
            return "The requirement '\(requirement)' is not possible to represent in Swift 3 package manifests."
        case .tagNotAvailable: return "The specified tag could not be found for this package."
        case .branchNotAvailable: return "The specified branch could not be found for this package."
        }
    }
}
