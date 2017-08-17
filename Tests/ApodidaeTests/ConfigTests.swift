import XCTest
@testable import ApodidaeCore

class ConfigTests: XCTestCase {
    func testSerialization() {
        let json = """
        {
          "githubAccessToken" : "foobar"
        }
        """.data(using: .utf8)!

        let config = try! JSONDecoder().decode(Config.self, from: json)
        XCTAssertEqual(config.githubAccessToken, "foobar")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try! encoder.encode(config)
        XCTAssertEqual(encoded, json)
    }

    static var allTests: [(String, (ConfigTests) -> () throws -> Void)] {
        return [
            ("testSerialization", testSerialization),
        ]
    }
    
}
