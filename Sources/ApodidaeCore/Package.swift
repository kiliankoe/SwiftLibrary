import Foundation
import Rainbow
import Releases

public struct Package: Decodable {
    public let name: String
    public let description: String
    public let gitCloneURL: URL
    public let latestVersion: String?
    public let stars: Int

    public var repository: URL {
        let urlString = self.gitCloneURL.absoluteString.replacingOccurrences(of: ".git", with: "")
        return URL(string: urlString)!
    }

    public var versions: [Version] {
        do {
            return try Releases.versions(for: self.gitCloneURL)
        } catch {
            print("Encountered error on fetching releases: \(error)")
            return []
        }
    }

    public var cliRepresentation: String {
        var output = """
        - \(self.name.bold) \(self.latestVersion ?? "")
          \((self.repository.absoluteString).italic)
        """
        if !self.description.isEmpty {
            output += "\n  \(self.description)"
        }
        return output
    }

    private enum CodingKeys: String, CodingKey {
        case name = "package_full_name"
        case description
        case gitCloneURL = "git_clone_url"
        case latestVersion = "latest_version"
        case stars = "stargazers_count"
    }

    private enum SourceKeys: String, CodingKey {
        case source = "_source"
    }

    public init(from decoder: Decoder) throws {
        let sourceContainer = try decoder.container(keyedBy: SourceKeys.self)
        let container = try sourceContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .source)

        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.gitCloneURL = try container.decode(URL.self, forKey: .gitCloneURL)
        self.latestVersion = try container.decodeIfPresent(String.self, forKey: .latestVersion)
        self.stars = try container.decode(Int.self, forKey: .stars)
    }
}
