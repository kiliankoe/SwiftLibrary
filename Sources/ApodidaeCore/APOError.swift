public enum APOError: Error {
    case invalidQuery
    case network
    case server(statusCode: Int)
}
