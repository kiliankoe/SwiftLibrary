import Foundation
import PromiseKit

protocol GraphQLQuery {
    associatedtype Response: Decodable
    var query: String { get }
    var variables: [String: String] { get }
    var header: [String: String] { get }
}

struct RepoQuery: GraphQLQuery {
    typealias Response = RepoResponse
    let query = """
    query ($query: String!) {
      search(query: $query, type: REPOSITORY, first: 100) {
        repositoryCount
        repositories: edges {
          node {
            ... on Repository {
              nameWithOwner
              description
              url
              isFork
              parent {
                nameWithOwner
              }
              isPrivate
              pushedAt
              license
              openIssues: issues(first: 0, states: OPEN) {
                totalCount
              }
              stargazers(first: 0) {
                totalCount
              }
              tags: refs(refPrefix: "refs/tags/", last: 5) {
                edges {
                  node {
                    name
                  }
                }
              }
              packageManifest: object(expression: "master:Package.swift") {
                ... on Blob {
                  abbreviatedOid
                }
              }
            }
          }
        }
      }
      rateLimit {
        remaining
        resetAt
      }
    }
    """
    let variables: [String: String]
    let header: [String: String]
    init(query: String, authToken: String) {
        self.variables = ["query": query]
        self.header = ["Authorization": "Bearer \(authToken)"]
    }
}

public struct RepoResponse: Decodable {
    let data: SearchResponse?
    let error: [ErrorResponse]?
}

public struct SearchResponse: Decodable {
    let repositoryCount: Int
    let repositories: [Repository]
    let rateLimitRemaining: Int
    let rateLimitResetAt: Date

    private enum SearchKeys: String, CodingKey {
        case search
        case rateLimit
    }

    private enum CodingKeys: String, CodingKey {
        case repositoryCount
        case repositories
    }

    private enum RateLimitKeys: String, CodingKey {
        case remaining
        case resetAt
    }

    public init(from decoder: Decoder) throws {
        let searchContainer = try decoder.container(keyedBy: SearchKeys.self)
        let container = try searchContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .search)
        self.repositoryCount = try container.decode(Int.self, forKey: .repositoryCount)
        self.repositories = try container.decode([Repository].self, forKey: .repositories)
        let rateLimitContainer = try searchContainer.nestedContainer(keyedBy: RateLimitKeys.self, forKey: .rateLimit)
        self.rateLimitRemaining = try rateLimitContainer.decode(Int.self, forKey: .remaining)
        self.rateLimitResetAt = try rateLimitContainer.decode(Date.self, forKey: .resetAt)
    }
}

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

public struct ErrorResponse: Decodable {
    let message: String
}

public enum GitHub {
    static let apiBaseURL = URL(string: "https://api.github.com/graphql")!

    static func send<T: GraphQLQuery>(query: T, isVerbose: Bool) -> Promise<T.Response> {
        var request = URLRequest(url: apiBaseURL)
        request.httpMethod = "POST"
        query.header.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        guard let variables = query.variables.asJSON else {
            return Promise(error: APOError.invalidQuery(reason: "Variables could not be encoded as JSON."))
        }
        request.httpBody = [
            "query": query.query,
            "variables": String(data: variables, encoding: .utf8) ?? "" // umm...
        ].asJSON
        return Network.dataTask(request: request, isVerbose: isVerbose)
    }

    public static func repos(with query: String, authToken: String, isVerbose: Bool) -> Promise<RepoResponse> {
        let repoQuery = RepoQuery(query: query, authToken: authToken)
        return send(query: repoQuery, isVerbose: isVerbose)
    }
}
