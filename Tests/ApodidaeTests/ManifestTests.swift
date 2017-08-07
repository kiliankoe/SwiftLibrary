import XCTest
@testable import ApodidaeCore
import Regex

class ManifestTests: XCTestCase {
    func testLineNumberOfMatches() {
        let barRegex = Regex("bar")

        let str1 = """
        foo
        bar
        baz
        """
        let barLines1 = barRegex.lineNumbersOfMatches(in: str1)
        XCTAssertEqual(barLines1, [1])

        let str2 = """
        bar
        foo
        bar
        """
        let barLines2 = barRegex.lineNumbersOfMatches(in: str2)
        XCTAssertEqual(barLines2, [0, 2])

        let str3 = """
        foo
        baz
        """
        let barLines3 = barRegex.lineNumbersOfMatches(in: str3)
        XCTAssertEqual(barLines3, [])
    }

    func testFindDependenciesInsert() {
        let manifestWithoutPackages = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
            ]
        )
        """

        let (line1, indentation1) = try! Manifest.findDependenciesInsertLocation(in: manifestWithoutPackages)
        XCTAssertEqual(line1, 5)
        XCTAssertEqual(indentation1, 8)

        let manifestWithPackages = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
                .package(url: "foo", from: ""),
                .package(url: "bar", from: ""),
                .package(url: "baz", from: ""),
            ]
        )
        """

        let (line2, indentation2) = try! Manifest.findDependenciesInsertLocation(in: manifestWithPackages)
        XCTAssertEqual(line2, 8)
        XCTAssertEqual(indentation2, 8)
    }

    func testFailingDependenciesInsert() {
        let manifestWithoutDependencies = """
        import PackageDescription

        let package = Package(
            name: "manifest"
        )
        """

        do {
            let _ = try Manifest.findDependenciesInsertLocation(in: manifestWithoutDependencies)
            XCTFail("Shouldn't find insert points in manifest without a list of dependencies.")
        } catch {
            XCTAssert(error is Manifest.Error)
        }
    }

    func testInsertPackageIntoManifestWithoutPackages() {
        let package = Repository(name: "kiliankoe/apodidae", url: "https://github.com/kiliankoe/apodidae")
        let manifestWithoutPackages = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
            ]
        )
        """
        let newManifest = try! Manifest.insert(package: package, requirement: .tag(package.latestVersion!), into: manifestWithoutPackages)

        let expected = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
                .Package(url: "https://github.com/kiliankoe/apodidae", majorVersion: 0, minor: 1),
            ]
        )
        """
        XCTAssertEqual(newManifest, expected)
    }

    func testInsertPackageIntoManifestWithPackages() {
        let package = Repository(name: "kiliankoe/apodidae", url: "https://github.com/kiliankoe/apodidae")
        let manifestWithPackages = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
                .package(url: "foo", from: ""),
                .package(url: "bar", from: ""),
            ]
        )
        """
        let newManifest = try! Manifest.insert(package: package, requirement: .tag(package.latestVersion!), into: manifestWithPackages)

        let expected = """
        import PackageDescription

        let package = Package(
            name: "manifest",
            dependencies: [
                .package(url: "foo", from: ""),
                .package(url: "bar", from: ""),
                .package(url: "https://github.com/kiliankoe/apodidae", from: "0.1.0"),
            ]
        )
        """
        XCTAssertEqual(newManifest, expected)
    }
}

extension Repository {
    init(name: String, url: String) {
        self.nameWithOwner = name
        self.url = URL(string: url)!

        self.description = ""
        self.isFork = false
        self.parent = nil
        self.isPrivate = false
        self.pushedAt = Date.distantPast
        self.license = nil
        self.openIssues = 0
        self.stargazers = 0
        self.tags = [Repository.Tag(name: "0.1.0")]
        self.hasPackageManifest = true
    }
}

extension Repository.Tag {
    init(name: String) {
        self.name = name
    }
}
