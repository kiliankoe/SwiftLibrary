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
        self.variables = ["query": "\(query) language:Swift"]
        self.header = ["Authorization": "Bearer \(authToken)"]
    }
}

public struct RepoResponse: Decodable {
    public let data: SearchResponse?
    public let error: [ErrorResponse]?
}

public struct SearchResponse: Decodable {
    public let repositoryCount: Int
    public let repositories: [Repository]
    public let rateLimitRemaining: Int
    public let rateLimitResetAt: Date

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
