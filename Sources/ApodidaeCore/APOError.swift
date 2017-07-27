import Foundation
import Rainbow

public enum APOError: Error {
    case invalidQuery
    case network
    case server(statusCode: Int)
}

extension APOError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidQuery:
            return "Invalid query.".red
        case .network:
            return "There was an issue with the network. Perhaps your connection?".red
        case .server(statusCode: let statusCode):
            switch statusCode {
            case 404:
                return "Could not find any data.".yellow
            case 409:
                return "This package already exists on the server.".yellow
            default:
                return "Server returned status \(statusCode).".red
            }
        }
    }
}

// Override `.localizedDescription` for APOErrors. Needs to be a `String?`, of course :P
extension APOError: LocalizedError {
    public var errorDescription: String? {
        return self.description
    }
}
