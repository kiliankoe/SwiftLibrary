import Foundation
import PromiseKit

enum Network {
    static func dataTask<T: Decodable>(request: URLRequest, isVerbose: Bool) -> Promise<T> {
        return Promise { fulfill, reject in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    reject(error!)
                    return
                }

                guard
                    let response = response as? HTTPURLResponse,
                    let data = data
                else {
                    reject(APOError.network)
                    return
                }

                guard response.statusCode / 100 == 2 else {
                    reject(APOError.server(statusCode: response.statusCode))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    fulfill(decoded)
                } catch let error {
                    reject(error)
                }
            }.resume()
        }
    }
}
