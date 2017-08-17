import XCTest
@testable import ApodidaeTests

XCTMain([
    testCase(CommandTests.allTests),
    testCase(GitHubTests.allTests),
    testCase(ManifestTests.allTests),
    testCase(RepositoryTests.allTests),
])
