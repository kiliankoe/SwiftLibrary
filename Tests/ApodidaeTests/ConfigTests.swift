import XCTest
@testable import ApodidaeCore

class ConfigTests: XCTestCase {
    func testSerialization() {
        let json = """
        {
          "librariesio_api_key" : "foobar",
          "disable_librariesio" : false
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertEqual(config.lioAPIKey, "foobar")
        XCTAssertEqual(config.disableLibrariesIO, false)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try! encoder.encode(config)
        XCTAssertEqual(encoded, json)
    }

    func testKeyEnabled() {
        let json = """
        {
          "librariesio_api_key" : "foobar",
          "disable_librariesio" : false
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertEqual(config.lioAPIKey, "foobar")
    }

    func testKeyButDisabled() {
        let json = """
        {
          "librariesio_api_key" : "foobar",
          "disable_librariesio" : true
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertNil(config.lioAPIKey)
    }

    func testEmptyKeyButEnabled() {
        let json = """
        {
          "librariesio_api_key" : "",
          "disable_librariesio" : false
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertNil(config.lioAPIKey)
    }

    func testEmptyKeyDisabled() {
        let json = """
        {
          "librariesio_api_key" : "",
          "disable_librariesio" : true
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertNil(config.lioAPIKey)
    }

    static var allTests = [
        ("testSerialization", testSerialization),
        ("testKeyEnabled", testKeyEnabled),
        ("testKeyButDisabled", testKeyButDisabled),
        ("testEmptyKeyButEnabled", testEmptyKeyButEnabled),
        ("testEmptyKeyDisabled", testEmptyKeyDisabled),
    ]
}
