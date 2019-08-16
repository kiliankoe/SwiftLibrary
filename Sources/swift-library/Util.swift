import Foundation
import Dispatch
import SwiftLibrary

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

func run(cmd: String, args: [String]) {
    let task = Process()
    task.launchPath = cmd
    task.arguments = args
    task.launch()
}

#if canImport(AppKit)
import AppKit
func addToPasteboard(string: String) {

    let pb = NSPasteboard.general
    pb.string(forType: .string)
    pb.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
    pb.setString(string, forType: .string)

}
#endif
