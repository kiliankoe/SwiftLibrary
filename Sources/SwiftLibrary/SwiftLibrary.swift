import Foundation

public enum SwiftLibrary {
    public static func query(_ query: String,
                             session: URLSession = .shared,
                             completion: @escaping (Result<[PackageData], Error>) -> Void) {
        let task = session.dataTask(with: urlRequest(with: query)) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let packages = try decoder.decode([PackageData].self, from: data)
                completion(.success(packages))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private static func urlRequest(with query: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.swiftpm.co"
        urlComponents.path = "/packages.json"
        let queryItem = URLQueryItem(name: "query", value: query)
        urlComponents.queryItems = [queryItem]
        guard let url = urlComponents.url else { fatalError("Failed to create URL") }
        return URLRequest(url: url)
    }
}
