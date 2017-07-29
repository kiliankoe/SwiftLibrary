import Foundation
import PromiseKit

enum Network {
    static func dataTask(request: URLRequest, isVerbose: Bool) -> Promise<Data> {
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

                fulfill(data)
            }.resume()
        }
    }

    static func dataTask<T: Decodable>(request: URLRequest, isVerbose: Bool) -> Promise<T> {
        return dataTask(request: request, isVerbose: isVerbose).then { data -> Promise<T> in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(T.self, from: data)
                return Promise(value: decoded)
            } catch let error {
                return Promise(error: error)
            }
        }
    }
}
