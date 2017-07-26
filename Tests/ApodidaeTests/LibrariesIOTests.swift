import XCTest
@testable import ApodidaeCore

class LibrariesIOTests: XCTestCase {
    func testDeserialization() {
        let json = """
        [
          {
            "name": "github.com/ReactiveX/RxSwift",
            "platform": "SwiftPM",
            "description": "Reactive Programming in Swift",
            "homepage": "",
            "repository_url": "https://github.com/ReactiveX/RxSwift",
            "normalized_licenses": [
              "MIT"
            ],
            "rank": 10,
            "latest_release_published_at": "2017-05-01T11:17:41.000Z",
            "latest_release_number": "3.4.1",
            "language": "Swift",
            "status": null,
            "package_manager_url": null,
            "stars": 10082,
            "forks": 1527,
            "keywords": [
              "functional",
              "ios",
              "observer",
              "reactive",
              "reactivex",
              "rxswift",
              "swift",
              "unidirectional"
            ],
            "latest_stable_release": {
              "id": 52306466,
              "repository_id": 382089,
              "name": "3.4.1",
              "sha": "102424379fb8d6c69b33b95c67504679042f44cc",
              "kind": "commit",
              "published_at": "2017-05-01T11:17:41.000Z",
              "created_at": "2017-05-18T08:13:36.614Z",
              "updated_at": "2017-05-18T08:13:36.614Z"
            },
            "versions": []
          }
        ]
        """.data(using: .utf8)!

        let packages = try! JSONDecoder().decode([LIOPackage].self, from: json)
        guard packages.count == 1 else {
            XCTFail("Packages should containt exactly one package")
            return
        }

        XCTAssertEqual(packages[0].name, "ReactiveX/RxSwift")
        XCTAssertEqual(packages[0].description, "Reactive Programming in Swift")
        XCTAssertEqual(packages[0].homepage?.absoluteString, nil)
        XCTAssertEqual(packages[0].repository.absoluteString, "https://github.com/ReactiveX/RxSwift")
        XCTAssertEqual(packages[0].latestVersion, "3.4.1")
    }

    func testSearch() {
        let e = expectation(description: "Get some data")

        let apiKey = ProcessInfo.processInfo.environment["LIBRARIESIO_APIKEY"]!
        LibrariesIO(withAPIKey: apiKey).search(query: "RxSwift", isVerbose: true).then { packages in
            print(packages)
            XCTAssert(packages.count > 0)
            e.fulfill()
        }.catch { error in
            XCTFail("Failed with error: \(error)")
            e.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}
