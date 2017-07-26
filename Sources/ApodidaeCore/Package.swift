import Foundation
import Rainbow

public protocol Package {
    var name: String { get }
    var description: String { get }
    var homepage: URL? { get }
    var repository: URL { get }
    var latestVersion: String? { get }
    var stars: Int { get }
    var source: Source { get }
}

extension Package {
    public var cliRepresentation: String {
        return """
        - \(self.name.bold) \(self.latestVersion ?? "") \(self.source)
          \((self.bestguessURL.absoluteString).italic)
          \(self.description)
        """
    }

    public var bestguessURL: URL {
        if let homepage = homepage {
            return homepage
        } else if !repository.absoluteString.contains("github.com/github.com") || !repository.absoluteString.contains("git@github.com") {
            // Oddly specific, but seems to occur rather frequently on libraries.io
            return repository
        }
        return URL(string: "https://github.com/\(name)")!
    }
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
