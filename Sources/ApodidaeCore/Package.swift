import Foundation

public struct Package {
    public let name: String
    public let description: String
    public let source: Source
    public let url: URL
    public let latestVersion: String?

    public init(from package: PCPackage) {
        self.name = package.name
        self.description = package.description
        self.source = .ibmpackagecatalog
        self.url = URL(string: package.url)!
        self.latestVersion = package.latestVersion
    }
}

extension Package {
    public enum Source {
        case ibmpackagecatalog
        case librariesio
    }
}
