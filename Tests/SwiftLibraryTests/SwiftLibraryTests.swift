import XCTest
@testable import SwiftLibrary

final class SwiftLibraryTests: XCTestCase {
    func testLiveFetch() {
        let e = expectation(description: "receive data")

        SwiftLibrary.query("Swift Package Manager") { result in
            switch result {
            case .failure(let error):
                XCTFail("Received error: \(error.localizedDescription)")
                e.fulfill()
            case .success(let packages):
                XCTAssertFalse(packages.isEmpty)
                e.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }
}
