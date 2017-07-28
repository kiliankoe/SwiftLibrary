import XCTest
@testable import ApodidaeCore

class PackageCatalogTests: XCTestCase {
    func testSearch() {
        let e = expectation(description: "Get some data")

        PackageCatalog.search(query: "apodidae", isVerbose: true).then { packages in
            XCTAssert(packages.count > 0)
            e.fulfill()
        }.catch { error in
            XCTFail("Failed with error: \(error)")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    static var allTests = [
        ("testSearch", testSearch),
    ]
}
