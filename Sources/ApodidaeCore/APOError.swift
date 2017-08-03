import Foundation
import Rainbow

public enum APOError: Error {
    case invalidQuery(reason: String)
    case network
    case server(statusCode: Int)
}

extension APOError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidQuery(let reason):
            return "Invalid query: \(reason)."
        case .network:
            return "There was an issue with the network. Perhaps your connection?"
        case .server(statusCode: let statusCode):
            switch statusCode {
            case 404:
                return "Could not find any data."
            case 409:
                return "This package already exists on the server."
            default:
                return "Server returned status \(statusCode)."
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
