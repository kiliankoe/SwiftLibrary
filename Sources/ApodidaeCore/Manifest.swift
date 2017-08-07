import Foundation
import Files
import Regex

public enum Manifest {

    public enum Error: Swift.Error {
        case unsupportedLayout(reason: String)
    }

    public static func findDependenciesInsertLocation(in manifest: String) throws -> (line: Int, indentation: Int) {
        let previousPackagesRegex = Regex("url: \"(\\S+)\",(.+)\\)")
        let dependenciesRegex = Regex("dependencies:\\s?\\[")
        let targetsRegex = Regex("target\\(", options: .ignoreCase)

        let previousPackages = previousPackagesRegex.allMatches(in: manifest)
        if previousPackages.count > 0 {
            guard let lastPackageLocation = previousPackagesRegex.lineNumbersOfMatches(in: manifest).last else {
                throw Error.unsupportedLayout(reason: "Found packages, but no packages. Wat. This shouldn't be happening o.O\nThis is considered a bug in apodidae. Please open an issue with your Package.swift, thanks!")
            }
            // FIXME: Indentation shouldn't be hardcoded
            // FIXME: Handle possibly missing trailing commas
            return (lastPackageLocation + 1, 8)
        } else {
            // List of dependencies is either empty or non-existant

            let targetsCount = targetsRegex.allMatches(in: manifest).count
            let dependenciesCount = dependenciesRegex.allMatches(in: manifest).count
            guard dependenciesCount > targetsCount else {
                // FIXME: This should obviously be improved...
                throw Error.unsupportedLayout(reason: "Found \(targetsCount) targets with \(dependenciesCount) dependencies. Can't safely distinguish.\nThis is considered a bug in apodidae. Please open an issue with your Package.swift, thanks!")
            }

            guard let dependenciesListLocation = dependenciesRegex.lineNumbersOfMatches(in: manifest).first else {
                throw Error.unsupportedLayout(reason: "Found no list of dependencies. Please make sure your Package.swift includes at least an empty list of dependencies.")
            }

            // FIXME: Indentation shouldn't be hardcoded
            // FIXME: What if it's "dependencies: []" with the closing bracket on the same line? Handle that.
            return (dependenciesListLocation + 1, 8)
        }
    }

    public static func insert(package: Repository, requirement: Requirement, into manifest: String) throws -> String {
        let swiftVersion = SwiftVersion.guessVersion(fromPackageContents: manifest)
        let (line, indentation) = try findDependenciesInsertLocation(in: manifest)

        var manifestLines = manifest
            .split(separator: "\n", omittingEmptySubsequences: false) // preserve whitespace
            .map(String.init)
        let packageString = try package.dependencyRepresentation(for: swiftVersion, requirement: requirement)
        let indentationPrefix = Array(repeating: " ", count: indentation).joined()
        manifestLines.insert("\(indentationPrefix)\(packageString)", at: line)
        return manifestLines.joined(separator: "\n")
    }

    public static func insertIntoLocalManifest(package: Repository, requirement: Requirement) throws {
        let localManifest = try Folder.current.file(named: "Package.swift").readAsString()
        let newManifest = try Manifest.insert(package: package, requirement: requirement, into: localManifest)
        try Folder.current.file(atPath: "Package.swift").write(string: newManifest)
    }
}

extension Regex {
    func lineNumbersOfMatches(in file: String) -> [Int] {
        return file
            .split(separator: "\n", omittingEmptySubsequences: false) // preserve whitespace
            .enumerated()
            .flatMap { arg -> Int? in
                let (offset, element) = arg
                if self.matches(String(element)) {
                    return offset
                }
                return nil
            }
    }
}

extension Manifest.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedLayout(let reason): return "The layout of your Package.swift is unsupported. \(reason)"
        }
    }
}
