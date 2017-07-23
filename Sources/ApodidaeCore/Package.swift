import Foundation

public struct Package {
    public let name: String
    public let description: String
    public let source: Source
    public let url: URL
    public let latestVersion: String
}

extension Package {
    public enum Source {
        case ibmpackagecatalog
        case librariesio
    }
}
