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

    public static func readFromLocalPackage() -> SwiftVersion {
        guard let packageManifest = try? Folder.current.file(named: "Package.swift").readAsString() else {
            return currentStable
        }
        if packageManifest.contains("swift-tools-version:3") {
            return .v3
        } else if packageManifest.contains("swift-tools-version:4") {
            return .v4
        } else {
            return currentStable
        }
    }
}
