import Foundation

public protocol Package {
    var name: String { get }
    var description: String { get }
    var homepage: URL? { get }
    var repository: URL { get }
    var latestVersion: String? { get }
    var stars: Int { get }
    var source: Source { get }
}

public enum Source {
    case ibmpackagecatalog
    case librariesio
}

extension PCPackage: Package {
    public var homepage: URL? {
        return self.repository
    }

    public var source: Source {
        return .ibmpackagecatalog
    }
}

extension LIOPackage: Package {
    public var source: Source {
        return .librariesio
    }
}
