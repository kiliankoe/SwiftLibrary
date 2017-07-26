import XCTest
@testable import ApodidaeCore

class CoreTests: XCTestCase {
    func testPCOnlySearch() {
        let e = expectation(description: "Find some packages")

        Core.searchAll(query: "rxswift", librariesIOApiKey: nil, isVerbose: true).then { packages in
            XCTAssert(packages.count > 0)
            e.fulfill()
        }.catch { error in
            XCTFail("Failed with error: \(error)")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testAllSearch() {
        let e = expectation(description: "Find some packages")

        Core.searchAll(query: "rxswift", librariesIOApiKey: ProcessInfo.processInfo.environment["LIBRARIESIO_APIKEY"]!, isVerbose: true).then { packages in
            XCTAssert(packages.count > 0)
            e.fulfill()
        }.catch { error in
            XCTFail("Failed with error: \(error)")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
