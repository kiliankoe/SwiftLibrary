import Foundation
import Files

public struct Config: Codable {
    private let librariesIOApiKey: String
    public let disableLibrariesIO: Bool?

    public var lioAPIKey: String? {
        // For future reference: The API Key is not an optional property on the config since I always want it written to the config file,
        // but an empty value is obviously not a valid value.
        if let lioDisabled = disableLibrariesIO, lioDisabled {
            return nil
        } else if librariesIOApiKey.isEmpty {
            return nil
        }
        return librariesIOApiKey
    }

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

    public func printLIOWarningIfNecessary() {
        if lioAPIKey == nil && !(disableLibrariesIO ?? false) {
            print("Searching only on packagecatalog.com. To search on libraries.io as well please copy your".yellow)
            print("API Key (found here: https://libraries.io/account) into \(Config.configFilePath).".yellow)
            print("Otherwise you may also optionally disable this warning via the config file.".yellow)
        }
    }
}
