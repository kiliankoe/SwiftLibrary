import XCTest
@testable import ApodidaeCore

class PackageInfoTests: XCTestCase {
    func testDeserialization() {
        let json = """
        {
          "blacklist": false,
          "id": 96880458,
          "image": "96880458.png",
          "name": "OpenMensaKit",
          "publisher": "kiliankoe",
          "description": "🍛 Query OpenMensa for canteen and meal data",
          "readme": "",
          "featured": false,
          "ghUrl": "https://github.com/kiliankoe/OpenMensaKit",
          "ghUrlSansHttp": "github.com/kiliankoe/OpenMensaKit",
          "published": "11 days ago",
          "license": "MIT License",
          "license_url": "https://api.github.com/licenses/mit",
          "version": "0.1.0",
          "swift_version": "N/A",
          "stars": 2,
          "favorited": false,
          "owned": false,
          "owner": 2625584,
          "sandbox": [],
          "dependencies": [],
          "dependents": [],
          "categories": [],
          "versions": [
            {
              "package_id": 96880458,
              "tag_string": "92e6a8e03849e44d947b8740d695d60a008a870f.0.1.0.96880458",
              "tag": "0.1.0",
              "sha": "92e6a8e03849e44d947b8740d695d60a008a870f",
              "read_me_file": "",
              "license_file": "",
              "last_crawled_at": "2017-07-26T19:12:30.557Z",
              "last_indexed_at": null,
              "isNew": true,
              "is_deleted": false,
              "description": null,
              "tag_date": "2017-07-11 14:08:06 +0200",
              "keywords": null,
              "swift_version_file": null
            }
          ]
        }
        """.data(using: .utf8)!

        let info = try! JSONDecoder().decode(PackageInfo.self, from: json)
        XCTAssertEqual(info.name, "OpenMensaKit")
        XCTAssertEqual(info.license, "MIT License")
        XCTAssertEqual(info.versions[0].tag, "0.1.0")
    }

    static var allTests = [
        ("testDeserialization", testDeserialization),
    ]
}
