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
        XCTAssertEqual(config.librariesIOApiKey, "foobar")
        XCTAssertEqual(config.disableLibrariesIO, false)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try! encoder.encode(config)
        XCTAssertEqual(encoded, json)
    }
}
