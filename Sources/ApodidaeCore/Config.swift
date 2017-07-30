import Foundation
import Files
import Rainbow

public struct Config: Codable {
    public let githubAccessToken: String

    public static let configFileName = ".apodidae.json"
    public static let configFilePath = "\(Folder.home.path)\(configFileName)"

    public static let tokenPlaceholder = "your-token-here"
    public static let tokenWarning = """
    Apodidae needs a GitHub access token to work since it calls the GitHub v4 GraphQL API. You can get
    your token here: \("https://github.com/settings/tokens".underline). Just click on "Generate new token", enter a
    description of your choice and select the \("repo".bold) or at least \("repo:public_repo".bold) scope. After generating
    copy this token into \(configFilePath.italic).

    That's it, you're good to go 👌
    """

    public static func read() throws -> Config {
        let data = try Folder.home.file(named: configFileName).read()
        return try JSONDecoder().decode(Config.self, from: data)
    }

    public static func initializeIfNecessary() throws {
        guard !Folder.home.containsFile(named: configFileName) else { return }

        let emptyConfig = Config(githubAccessToken: tokenPlaceholder)
        let configFile = try Folder.home.createFile(named: configFileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(emptyConfig)
        try configFile.write(data: data)
    }
}
