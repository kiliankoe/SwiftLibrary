import Foundation
import PromiseKit
import Rainbow

public enum Core {
    public static func searchAll(query: String, librariesIOApiKey: String?, isVerbose: Bool) -> Promise<[Package]> {
        if let librariesIOApiKey = librariesIOApiKey {
            let librariesIO = LibrariesIO(withAPIKey: librariesIOApiKey)

            let pcPromise = PackageCatalog.search(query: query, isVerbose: isVerbose).then { p in p.map({ $0 as Package}) }
            let lioPromise = librariesIO.search(query: query, isVerbose: isVerbose).then { p in p.map({ $0 as Package }) }
            return when(resolved: [pcPromise, lioPromise]).then { results in
                // TODO: All of this feels far from ideal, fix it!
                var allPackages = [Package]()

                // I believe this array access shouldn't be able to fail, can I be sure?
                let pcResult = results[0]
                let lioResult = results[1]

                switch pcResult {
                case .fulfilled(let packages):
                    allPackages += packages
                case .rejected(let error):
                    print("Encountered the following error with packagecatalog.com: \(error)".yellow)
                }

                switch lioResult {
                case .fulfilled(let packages):
                    allPackages += packages
                case .rejected(let error):
                    print("Encountered the following error with libraries.io: \(error)".yellow)
                }

                return Promise(value: allPackages)
            }
        } else {
            return PackageCatalog.search(query: query, isVerbose: isVerbose).then { packages in
                return Promise(value: packages.map({ $0 as Package }))
            }
        }
    }
}
