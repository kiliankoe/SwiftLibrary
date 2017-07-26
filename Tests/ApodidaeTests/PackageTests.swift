import XCTest
@testable import ApodidaeCore

class PackageTests: XCTestCase {
    func testDeserialization() {
        let json = """
        {
            "header": {
                "totalResult": 1,
                "links": {
                    "first": "/api/v1/search/mxcl%2FPromiseKit?page=1&items=100&chart=moststarred",
                    "next": "null&chart=moststarred",
                    "previous": "/api/v1/search/mxcl%2FPromiseKit?page=1&items=100&chart=moststarred",
                    "last": "/api/v1/search/mxcl%2FPromiseKit?page=1&items=100&chart=moststarred"
                }
            },
            "error": false,
            "data": {
                "timed_out": false,
                "took": 1,
                "_shards": {
                    "successful": 5,
                    "total": 5,
                    "failed": 0
                },
                "hits": {
                    "hits": [{
                        "sort": [
                        7962],
                        "_index": "package",
                        "_source": {
                            "package_full_name": "mxcl/PromiseKit",
                            "stargazers_count": 7962,
                            "git_clone_url": "https://github.com/mxcl/PromiseKit.git",
                            "latest_version": "4.2.1",
                            "suggest": {
                                "input": [
                                    "PromiseKit",
                                    "mxcl/PromiseKit"],
                                "output": "mxcl/PromiseKit",
                                "weight": 7962,
                                "payload": {
                                    "f1": "Promises for Swift & ObjC",
                                    "f2": false
                                }
                            },
                            "swift_version_file": null,
                            "updated_at": "2017-07-23T21:45:11.000-05:00",
                            "description": "Promises for Swift & ObjC",
                            "package_name": "PromiseKit",
                            "blacklist": false,
                            "categories": null
                        },
                        "_score": null,
                        "_id": "18440563",
                        "_type": "jdbc"
                    }],
                    "total": 1,
                    "max_score": null
                }
            }
        }
        """.data(using: .utf8)!

        let response = try! JSONDecoder().decode(PCResponse.self, from: json)
        guard response.packages.count == 1 else {
            XCTFail("Response should contain exactly one package")
            return
        }
        XCTAssertEqual(response.packages[0].name, "mxcl/PromiseKit")
        XCTAssertEqual(response.packages[0].description, "Promises for Swift & ObjC")
        XCTAssertEqual(response.packages[0].repository.absoluteString, "https://github.com/mxcl/PromiseKit")
        XCTAssertEqual(response.packages[0].latestVersion, "4.2.1")
    }
}
