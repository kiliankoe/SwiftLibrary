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
        self.variables = ["query": "\(query) language:Swift fork:true"]
        self.header = ["Authorization": "Bearer \(authToken)"]
    }
}

public struct RepoResponse: Decodable {
    public let data: SearchResponse?
    public let errors: [ErrorResponse]?
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
        let repositories = try container.decode([Repository].self, forKey: .repositories)
        self.repositories = repositories.filter { $0.hasPackageManifest }
        let rateLimitContainer = try searchContainer.nestedContainer(keyedBy: RateLimitKeys.self, forKey: .rateLimit)
        self.rateLimitRemaining = try rateLimitContainer.decode(Int.self, forKey: .remaining)
        self.rateLimitResetAt = try rateLimitContainer.decode(Date.self, forKey: .resetAt)
    }
}

public struct ErrorResponse: Decodable, Error, LocalizedError {
    let message: String

    public var errorDescription: String? {
        return "GitHub API Error: \(message)".red
    }
}

public enum GitHub {
    public enum Error: Swift.Error, LocalizedError {
        case noPackages

        public var errorDescription: String? {
            switch self {
            case .noPackages: return "No packages found.".yellow
            }
        }
    }

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

    public static func repos(with query: String, authToken: String, isVerbose: Bool) -> Promise<[Repository]> {
        let repoQuery = RepoQuery(query: query, authToken: authToken)
        return send(query: repoQuery, isVerbose: isVerbose).then { response in
            // This is just for some pre-processing for errors and verbosity
            if let error = response.errors?.first {
                throw error
            }
            if isVerbose {
                print("Found \(response.data?.repositoryCount ?? 0) possible repositories on GitHub, \(response.data?.repositories.count ?? 0) of which seem to include a Package.swift.")
                print("You have \(response.data?.rateLimitRemaining ?? 0)/5000 API requests remaining, which will be reset on \(response.data?.rateLimitResetAt.iso ?? "?").")
                print()
            }

            guard let repos = response.data?.repositories else {
                throw GitHub.Error.noPackages
            }

            return Promise(value: repos)
        }
    }

    public static func firstRepo(with query: String, authToken: String, isVerbose: Bool) -> Promise<Repository> {
        return repos(with: query, authToken: authToken, isVerbose: isVerbose).then { repos in
            guard let first = repos.first else {
                throw GitHub.Error.noPackages
            }
            return Promise(value: first)
        }
    }
}
