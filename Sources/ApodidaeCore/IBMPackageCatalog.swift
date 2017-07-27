import Foundation
import PromiseKit

struct PCResponse: Decodable {
    let packages: [Package]

    private enum RootKeys: String, CodingKey {
        case data
    }

    private enum DataKeys: String, CodingKey {
        case hits
    }

    private enum HitsKeys: String, CodingKey {
        case hits
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let hitsContainer = try dataContainer.nestedContainer(keyedBy: HitsKeys.self, forKey: .hits)
        self.packages = try hitsContainer.decode([Package].self, forKey: .hits)
    }
}

public enum PackageCatalog {
    public static func search(query: String, isVerbose: Bool) -> Promise<[Package]> {
        if isVerbose { print("Searching for \(query) on packagecatalog.com...") }

        guard
            let escaped = query.urlHostEscaped,
            let url = URL(string: "https://packagecatalog.com/api/search/\(escaped)?page=1&items=100&chart=moststarred")
        else {
            return Promise(error: APOError.invalidQuery)
        }

        let request = URLRequest(url: url)
        return Network.dataTask(request: request, isVerbose: isVerbose).then { (response: PCResponse) in
            return Promise(value: response.packages)
        }
    }

    public static func getInfo(for package: String, isVerbose: Bool) -> Promise<PackageInfo> {
        if isVerbose { print("Searching for \(package)'s details on packagecatalog.com...") }

        guard let url = URL(string: "https://packagecatalog.com/data/package/\(package)") else {
            return Promise(error: APOError.invalidQuery)
        }

        let request = URLRequest(url: url)
        return Network.dataTask(request: request, isVerbose: isVerbose)
    }

    public static func submit(url: URL, isVerbose: Bool) -> Promise<Data> {
        if isVerbose { print("Submitting \(url.absoluteString) to packagecatalog.com...") }
        let url = URL(string: "https://packagecatalog.com/api/packages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "{\"giturl\": \"\(url.absoluteString)\"}".data(using: .utf8)
        return Network.dataTask(request: request, isVerbose: isVerbose)
    }
}
