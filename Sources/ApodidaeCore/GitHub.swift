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
        cost
        remaining
        resetAt
      }
    }
    """
    let variables: [String: String]
    let header: [String: String]
    init(query: String, accessToken: String, searchForks: Bool) {
        var queryString = "\(query) language:Swift" // TODO: would in:name,description be a good idea here?
        if searchForks {
            queryString += " fork:true"
        }
        self.variables = ["query": queryString]
        self.header = ["Authorization": "Bearer \(accessToken)"]
    }
}

public struct RepoResponse: Decodable {
    public let data: SearchResponse?
    public let errors: [ErrorResponse]?
}

public struct SearchResponse: Decodable {
    public let repositoryCount: Int
    public let repositories: [Repository]
    public let queryCost: Int
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
        case cost
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
        self.queryCost = try rateLimitContainer.decode(Int.self, forKey: .cost)
        self.rateLimitRemaining = try rateLimitContainer.decode(Int.self, forKey: .remaining)
        self.rateLimitResetAt = try rateLimitContainer.decode(Date.self, forKey: .resetAt)
    }
}

public struct ErrorResponse: Decodable, Error, LocalizedError {
    let message: String

    public var errorDescription: String? {
        return "GitHub API Error: \(message)"
    }
}

public enum GitHub {
    public enum Error: Swift.Error, LocalizedError {
        case noPackages

        public var errorDescription: String? {
            switch self {
            case .noPackages: return "No packages found."
            }
        }
    }

    public struct MetaInfo {
        let totalRepositoryCount: Int
        let swiftPackageCount: Int
        let rateLimitRemaining: Int
        let rateLimitResetAt: Date
        let queryCost: Int

        init(from response: SearchResponse) {
            self.totalRepositoryCount = response.repositoryCount
            self.swiftPackageCount = response.repositories.count
            self.rateLimitRemaining = response.rateLimitRemaining
            self.rateLimitResetAt = response.rateLimitResetAt
            self.queryCost = response.queryCost
        }

        public var cliRepresentation: String {
            return """
            Found \(totalRepositoryCount) possible repositories on GitHub, \(swiftPackageCount) out of the top 100 of which seem to include a Package.swift.
            You have ~\(rateLimitRemaining/queryCost)/\(5000 / queryCost) API requests remaining, which will be reset on \(rateLimitResetAt.iso).

            """
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

    public static func repos(with query: String, accessToken: String, searchForks: Bool, isVerbose: Bool) -> Promise<[Repository]> {
        let repoQuery = RepoQuery(query: query, accessToken: accessToken, searchForks: searchForks)
        return send(query: repoQuery, isVerbose: isVerbose).then { response in
            if let error = response.errors?.first {
                throw error
            }
            if isVerbose {
                print("Found \(response.data?.repositoryCount ?? 0) possible repositories on GitHub, \(response.data?.repositories.count ?? 0) out of the top 100 of which seem to include a Package.swift.")
                print("You have ~\((response.data?.rateLimitRemaining ?? 0)/(response.data?.queryCost ?? 1))/\(5000 / (response.data?.queryCost ?? 1)) API requests remaining, which will be reset on \(response.data?.rateLimitResetAt.iso ?? "?").")
                print()
            }

            guard let repos = response.data?.repositories, repos.count > 0 else {
                throw GitHub.Error.noPackages
            }

            return Promise(value: repos)
        }
    }

    public static func firstRepo(with query: String, accessToken: String, searchForks: Bool, isVerbose: Bool) -> Promise<Repository> {
        return repos(with: query, accessToken: accessToken, searchForks: searchForks, isVerbose: isVerbose).then { repos in
            guard let first = repos.first else {
                throw GitHub.Error.noPackages
            }
            return Promise(value: first)
        }
    }
}
