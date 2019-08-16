import SwiftLibrary
import Dispatch

func allPackages(query: String) -> [PackageData] {
    let semaphore = DispatchSemaphore(value: 0)

    var packages: [PackageData] = []

    SwiftLibrary.query(query) { result in
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
            semaphore.signal()
        case .success(let fetchedPackages):
            packages = fetchedPackages
            semaphore.signal()
        }
    }

    semaphore.wait()
    return packages
}

func firstPackage(query: String) -> PackageData? {
    return allPackages(query: query).first
}
