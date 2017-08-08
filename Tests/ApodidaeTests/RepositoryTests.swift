import XCTest
@testable import ApodidaeCore

class RepositoryTests: XCTestCase {
    func testNameAndOwner() {
        let repo = Repository(name: "kiliankoe/apodidae", url: "https://github.com/kiliankoe/apodidae")
        XCTAssertEqual(repo.name, "apodidae")
        XCTAssertEqual(repo.owner, "kiliankoe")
    }

    func testLatestVersion() {
        var repo = Repository(name: "kiliankoe/apodidae", url: "https://github.com/kiliankoe/apodidae")
        XCTAssertEqual(repo.latestVersion, "0.1.0")

        repo.tags = ["0.2.0", "1.0.0"]
        XCTAssertEqual(repo.latestVersion, "1.0.0")
    }

    func testDependencyRepresentation() {
        let repo = Repository(name: "kiliankoe/apodidae", url: "https://github.com/kiliankoe/apodidae")

        let swift4Latest = try! repo.dependencyRepresentation(for: .v4, requirement: .tag("0.1.0"))
        XCTAssertEqual(swift4Latest, ".package(url: \"https://github.com/kiliankoe/apodidae\", from: \"0.1.0\"),")

        let swift4Master = try! repo.dependencyRepresentation(for: .v4, requirement: .branch("master"))
        XCTAssertEqual(swift4Master, ".package(url: \"https://github.com/kiliankoe/apodidae\", .branch(\"master\")),")

        let swift4Revision = try! repo.dependencyRepresentation(for: .v4, requirement: .revision("foobar"))
        XCTAssertEqual(swift4Revision, ".package(url: \"https://github.com/kiliankoe/apodidae\", .revision(\"foobar\")),")

        let swift3Representable = try! repo.dependencyRepresentation(for: .v3, requirement: .tag("0.1.0"))
        XCTAssertEqual(swift3Representable, ".Package(url: \"https://github.com/kiliankoe/apodidae\", majorVersion: 0, minor: 1),")

        do {
            let _ = try repo.dependencyRepresentation(for: .v3, requirement: .branch("master"))
            XCTFail("Branch requirement should not be representable in Swift 3.")
        } catch {
            XCTAssert(error is Repository.DependencyRepresentationError)
        }

        do {
            let _ = try repo.dependencyRepresentation(for: .v3, requirement: .revision("foobar"))
            XCTFail("Revision requirement should not be representable in Swift 3.")
        } catch {
            XCTAssert(error is Repository.DependencyRepresentationError)
        }
    }
}
