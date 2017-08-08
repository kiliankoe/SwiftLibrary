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
                      "abbreviatedOid": "3571935"
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
                      "abbreviatedOid": "5338ca5"
                    }
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
                      "abbreviatedOid": "dcc137a"
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
              "cost": 3,
              "remaining": 4797,
              "resetAt": "2017-07-30T11:41:21Z"
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

    static var allTests = [
        ("testDeserialization", testDeserialization),
//        ("testGitHubRequest", testGitHubRequest),
    ]
}
