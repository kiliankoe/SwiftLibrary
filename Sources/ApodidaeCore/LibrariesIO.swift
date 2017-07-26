import Foundation
import PromiseKit

public struct LIOPackage: Decodable {
    public let name: String
    public let description: String
    public let homepage: URL?
    public let repository: URL
    public let licenses: [String]
    public let latestVersion: String?
    public let stars: Int

    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case homepage
        case repository = "repository_url"
        case licenses = "normalized_licenses"
        case latestVersion = "latest_release_number"
        case stars
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawName = try container.decode(String.self, forKey: .name)
        self.name = rawName
            .replacingOccurrences(of: "github.com/", with: "")
            .replacingOccurrences(of: "git@github.com:", with: "")
        self.description = try container.decode(String.self, forKey: .description)
        let rawHomepageString = try container.decodeIfPresent(String.self, forKey: .homepage)
        if
            let rawHomepageString = rawHomepageString,
            !rawHomepageString.isEmpty,
            let homepage = URL(string: rawHomepageString)
        {
            self.homepage = homepage
        } else {
            self.homepage = nil
        }
        self.repository = try container.decode(URL.self, forKey: .repository)
        self.licenses = try container.decode([String].self, forKey: .licenses)
        self.latestVersion = try container.decodeIfPresent(String.self, forKey: .latestVersion)
        self.stars = try container.decode(Int.self, forKey: .stars)
    }
}

public struct LibrariesIO {
    let apiKey: String

    public init(withAPIKey key: String) {
        self.apiKey = key
    }

    public func search(query: String, isVerbose: Bool) -> Promise<[LIOPackage]> {
        if isVerbose { print("Searching for \(query) on libraries.io...") }

        let params = [
            "q": query,
            "api_key": self.apiKey,
            "platforms": "SwiftPM"
        ]

        guard let url = URL(string: "https://libraries.io/api/search?\(params.urlEncoded)") else {
            return Promise(error: Error.invalidQuery)
        }

        let request = URLRequest(url: url)
        return Network.dataTask(request: request, isVerbose: isVerbose)
    }
}
