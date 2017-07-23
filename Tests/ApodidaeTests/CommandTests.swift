import XCTest
@testable import ApodidaeCore

class CommandTests: XCTestCase {
    func testInit() {
        let validCommands = [
            ["search", "foo"],
            ["s", "bar"],
            ["add", "baz"],
            ["a", "foo"],
            ["remove", "bar"],
            ["r", "baz"],
            ["list"],
            ["l"],
        ]
        for command in validCommands {
            guard let _ = Command(from: command) else {
                XCTFail("Failed to initialize valid command")
                return
            }
        }

        let invalidCommands = [
            ["install"],
            ["foobar"],
        ]
        for command in invalidCommands {
            if let _ = Command(from: command) {
                XCTFail("Initialized invalid command")
            }
        }
    }

    static var allTests = [
        ("testInit", testInit)
    ]
}
