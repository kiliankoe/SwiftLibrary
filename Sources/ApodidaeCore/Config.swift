import Foundation
import Files

public struct Config: Codable {
    public let librariesIOApiKey: String
    public let disableLibrariesIO: Bool?

    public static let configFileName = ".apodidae.json"
    public static let configFilePath = "\(Folder.home.path)\(Config.configFileName)"

    private enum CodingKeys: String, CodingKey {
        case librariesIOApiKey = "librariesio_api_key"
        case disableLibrariesIO = "disable_librariesio"
    }

    public static func read() throws -> Config {
        let data = try Folder.home.file(named: configFileName).read()
        return try JSONDecoder().decode(Config.self, from: data)
    }

    public static func initializeIfNecessary() throws {
        guard !Folder.home.containsFile(named: configFileName) else { return } // this doesn't check the contents of the config file
        let emptyConfig = Config(librariesIOApiKey: "", disableLibrariesIO: false)
        let configFile = try Folder.home.createFile(named: configFileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(emptyConfig)
        try configFile.write(data: data)
    }
}
