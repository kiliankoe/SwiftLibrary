import XCTest
@testable import ApodidaeTests

XCTMain([
    testCase(CommandTests.allTests),
    testCase(ConfigTests.allTests),
    testCase(GitHubTests.allTests),
    testCase(ManifestTests.allTests),
    testCase(RepositoryTests.allTests),
])
