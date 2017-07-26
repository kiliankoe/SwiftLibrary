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
            return Promise(error: Error.invalidQuery)
        }

        let request = URLRequest(url: url)
        return Network.dataTask(request: request, isVerbose: isVerbose).then { (response: PCResponse) in
            return Promise(value: response.packages)
        }
    }
}
