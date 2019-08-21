import XCTest
@testable import SwiftLibrary

class CommandTests: XCTestCase {
    func testInit() {
        let validCommands = [
            ["search", "foo"],
            ["s", "bar"],
            ["info", "foo"],
            ["i", "bar"],
            ["home", "foo"],
            ["h", "bar"],
            ["add", "baz"],
            ["a", "foo"],
            ["+", "bar"],
        ]
        for command in validCommands {
            if Command(from: command) == nil {
                XCTFail("Failed to initialize valid command with \(command)")
                return
            }
        }

        let invalidCommands = [
            ["install"],
            ["foobar"],
        ]
        for command in invalidCommands {
            if Command(from: command) != nil {
                XCTFail("Initialized invalid command")
            }
        }
    }

    func testSimpleQueries() {
        XCTAssertEqual(Command(from: ["search", "foo", "bar"])!, Command.search("foo bar"))
        XCTAssertEqual(Command(from: ["info", "foo", "bar"])!, Command.info("foo bar"))
        XCTAssertEqual(Command(from: ["home", "foo", "bar"])!, Command.home("foo bar"))
        XCTAssertEqual(Command(from: ["add", "foo", "bar"])!, Command.add(package: "foo bar", requirement: nil))
    }

    func testAdd() {
        XCTAssertEqual(Command(from: ["add", "foobar"])!, Command.add(package: "foobar", requirement: nil))
        XCTAssertEqual(Command(from: ["add", "foobar@1.1.0"])!, Command.add(package: "foobar", requirement: .tag("1.1.0")))
        XCTAssertEqual(Command(from: ["add", "foobar@tag:1.1.0"]), Command.add(package: "foobar", requirement: .tag("1.1.0")))
        XCTAssertEqual(Command(from: ["add", "foobar@version:1.1.0"]), Command.add(package: "foobar", requirement: .tag("1.1.0")))
        XCTAssertEqual(Command(from: ["add", "foobar@branch:master"]), Command.add(package: "foobar", requirement: .branch("master")))
        XCTAssertEqual(Command(from: ["add", "foobar@revision:barfoo"]), Command.add(package: "foobar", requirement: .revision("barfoo")))
        XCTAssertEqual(Command(from: ["add", "foobar@commit:barfoo"]), Command.add(package: "foobar", requirement: .revision("barfoo")))

        XCTAssertNil(Command(from: ["add", "foobar@"]))
        XCTAssertNil(Command(from: ["add", "foobar@foo:bar"]))
        XCTAssertNil(Command(from: ["add", "foobar@:bar"]))
        XCTAssertNil(Command(from: ["add", "foobar@ "]))
    }

    func testEquality() {
        XCTAssertEqual(Command.search("foo"), Command.search("foo"))
        XCTAssertNotEqual(Command.search("foo"), Command.search("bar"))

        XCTAssertEqual(Command.info("foo"), Command.info("foo"))
        XCTAssertNotEqual(Command.info("foo"), Command.info("bar"))

        XCTAssertEqual(Command.home("foo"), Command.home("foo"))
        XCTAssertNotEqual(Command.home("foo"), Command.home("bar"))

        XCTAssertEqual(Command.add(package: "foo", requirement: .tag("0.1.0")), Command.add(package: "foo", requirement: .tag("0.1.0")))
        XCTAssertNotEqual(Command.add(package: "foo", requirement: .tag("0.1.0")), Command.add(package: "bar", requirement: .tag("0.1.0")))
        XCTAssertNotEqual(Command.add(package: "foo", requirement: .tag("0.1.0")), Command.add(package: "foo", requirement: .tag("1.0.0")))
        XCTAssertNotEqual(Command.add(package: "foo", requirement: .tag("0.1.0")), Command.add(package: "bar", requirement: .tag("1.0.0")))

        XCTAssertNotEqual(Command.info("foo"), Command.add(package: "foo", requirement: .tag("1.0.0")))
    }    
}
