import Files

public enum SwiftVersion {
    case v3
    case v4

    public init?(from int: Int) {
        switch int {
        case 3: self = .v3
        case 4: self = .v4
        default: return nil
        }
    }

    public static var currentStable: SwiftVersion = .v3

    public static func readFromLocalPackage() throws -> SwiftVersion {
        return try readFrom(packageManifest: Folder.current.file(named: "Package.swift"))
    }

    public static func readFrom(packageManifest: File) throws -> SwiftVersion {
        let manifest = try packageManifest.readAsString()
        return guessVersion(fromPackageContents: manifest)
    }

    public static func guessVersion(fromPackageContents manifest: String) -> SwiftVersion {
        if manifest.contains("swift-tools-version:3") || manifest.contains(".Package") {
            return .v3
        } else if manifest.contains("swift-tools-version:4") || manifest.contains(".package") {
            // Checking for `.package` for v4 will fail on future swift versions. It should just be here temporarily...
            return .v4
        } else {
            return currentStable
        }
    }
}
