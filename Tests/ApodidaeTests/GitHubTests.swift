import XCTest
@testable import ApodidaeCore

class GitHubTests: XCTestCase {
    func testDeserialization() {
        let json = """
        {
          "data": {
            "search": {
              "repositoryCount": 7,
              "repositories": [
                {
                  "node": {
                    "nameWithOwner": "kiliankoe/DVB",
                    "description": "🚆 Query Dresden's public transport system for current bus- and tramstop data in swift",
                    "url": "https://github.com/kiliankoe/DVB",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2017-05-30T13:42:44Z",
                    "license": "MIT License",
                    "openIssues": {
                      "totalCount": 4
                    },
                    "stargazers": {
                      "totalCount": 11
                    },
                    "packageManifest": {
                      "text": "import PackageDescription\\n\\nlet package = Package(\\n    name: \\"DVB\\",\\n    dependencies: [\\n        .Package(url: \\"https://github.com/utahiosmac/Marshal\\", majorVersion: 1, minor: 2),\\n        .Package(url: \\"https://github.com/kiliankoe/gausskrueger\\", majorVersion: 0, minor: 3),\\n    ]\\n)\\n"
                    }
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "kiliankoe/alfred_emeal",
                    "description": "List your latest Emeal transactions",
                    "url": "https://github.com/kiliankoe/alfred_emeal",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2017-07-17T22:15:03Z",
                    "license": null,
                    "openIssues": {
                      "totalCount": 0
                    },
                    "stargazers": {
                      "totalCount": 0
                    },
                    "packageManifest": {
                      "text": "// swift-tools-version:4.0\\n// The swift-tools-version declares the minimum version of Swift required to build this package.\\n\\nimport PackageDescription\\n\\nlet package = Package(\\n    name: \\"alfred_emeal\\",\\n    dependencies: [\\n        // Dependencies declare other packages that this package depends on.\\n        // .package(url: /* package url */, from: \\"1.0.0\\"),\\n        .package(url: \\"https://github.com/benchr267/swiftalfred\\", .branch(\\"master\\")),\\n        .package(url: \\"https://github.com/kiliankoe/StuWeDD\\", from: \\"0.2.1\\")\\n    ],\\n    targets: [\\n        // Targets are the basic building blocks of a package. A target can define a module or a test suite.\\n        // Targets can depend on other targets in this package, and on products in packages which this package depends on.\\n        .target(\\n            name: \\"alfred_emeal\\",\\n            dependencies: [\\"SwiftAlfred\\", \\"StuWeDD\\"]),\\n    ]\\n)\\n"
                    }
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "kiliankoe/campusnavigator",
                    "description": "🗺 Campus Navigator",
                    "url": "https://github.com/kiliankoe/campusnavigator",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": true,
                    "pushedAt": "2017-02-17T21:06:10Z",
                    "license": null,
                    "openIssues": {
                      "totalCount": 22
                    },
                    "stargazers": {
                      "totalCount": 0
                    },
                    "packageManifest": null
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "kiliankoe/StuWeDD",
                    "description": "🎓 Studentenwerk Dresden",
                    "url": "https://github.com/kiliankoe/StuWeDD",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2017-07-16T21:37:43Z",
                    "license": "MIT License",
                    "openIssues": {
                      "totalCount": 1
                    },
                    "stargazers": {
                      "totalCount": 0
                    },
                    "packageManifest": {
                      "text": "// swift-tools-version:4.0\\n// The swift-tools-version declares the minimum version of Swift required to build this package.\\n\\nimport PackageDescription\\n\\nlet package = Package(\\n    name: \\"StuWeDD\\",\\n    products: [\\n        // Products define the executables and libraries produced by a package, and make them visible to other packages.\\n        .library(\\n            name: \\"StuWeDD\\",\\n            targets: [\\"StuWeDD\\"]),\\n    ],\\n    dependencies: [\\n        // Dependencies declare other packages that this package depends on.\\n        // .package(url: /* package url */, from: \\"1.0.0\\"),\\n    ],\\n    targets: [\\n        // Targets are the basic building blocks of a package. A target can define a module or a test suite.\\n        // Targets can depend on other targets in this package, and on products in packages which this package depends on.\\n        .target(\\n            name: \\"StuWeDD\\",\\n            dependencies: []),\\n        .testTarget(\\n            name: \\"StuWeDDTests\\",\\n            dependencies: [\\"StuWeDD\\"]),\\n    ]\\n)\\n"
                    }
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "HTWDD/htwcampus",
                    "description": "Die iOS App der HTW Dresden",
                    "url": "https://github.com/HTWDD/htwcampus",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2017-07-10T07:30:41Z",
                    "license": "MIT License",
                    "openIssues": {
                      "totalCount": 7
                    },
                    "stargazers": {
                      "totalCount": 3
                    },
                    "packageManifest": null
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "BenchR267/mcdd15-watchkit",
                    "description": "This is a presentation and Xcode projects for a WatchKit session at mobilecamp 2015 in Dresden.",
                    "url": "https://github.com/BenchR267/mcdd15-watchkit",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2015-04-25T06:58:39Z",
                    "license": null,
                    "openIssues": {
                      "totalCount": 0
                    },
                    "stargazers": {
                      "totalCount": 1
                    },
                    "packageManifest": null
                  }
                },
                {
                  "node": {
                    "nameWithOwner": "kiliankoe/emeal",
                    "description": ":spaghetti: iOS companion for your daily TU Dresden canteen visit",
                    "url": "https://github.com/kiliankoe/emeal",
                    "isFork": false,
                    "parent": null,
                    "isPrivate": false,
                    "pushedAt": "2017-06-08T16:16:16Z",
                    "license": null,
                    "openIssues": {
                      "totalCount": 19
                    },
                    "stargazers": {
                      "totalCount": 1
                    },
                    "packageManifest": null
                  }
                }
              ]
            },
            "rateLimit": {
              "cost": 2,
              "remaining": 4984,
              "resetAt": "2017-08-09T09:33:42Z"
            }
          }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        let response = try! decoder.decode(RepoResponse.self, from: json)

        XCTAssertEqual(response.data?.repositories.count, 3)
        XCTAssertEqual(response.data?.repositories[0].nameWithOwner, "kiliankoe/DVB")
        XCTAssertTrue(response.data?.repositories[0].hasPackageManifest ?? false)
        XCTAssertEqual(response.data?.repositories[0].dependencies ?? [], ["utahiosmac/Marshal", "kiliankoe/gausskrueger"])
    }

//    func testGitHubRequest() {
//        let e = expectation(description: "Get some data")
//
//        let authToken = ProcessInfo.processInfo.environment["GITHUB_AUTHKEY"]!
//        GitHub.repos(with: "kiliankoe/apodidae", authToken: authToken, isVerbose: false).then { response in
//            XCTAssert(response.data?.repositories.count ?? 0 > 0)
//            e.fulfill()
//        }.catch { error in
//            XCTFail("Failed with error: \(error)")
//            e.fulfill()
//        }
//
//        waitForExpectations(timeout: 5)
//    }

    static var allTests: [(String, (GitHubTests) -> () throws -> Void)] {
        return [
            ("testDeserialization", testDeserialization),
//        ("testGitHubRequest", testGitHubRequest),
        ]
    }
}
