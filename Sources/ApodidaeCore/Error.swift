public enum Error: Swift.Error {
    case invalidQuery
    case network
    case server(statusCode: Int)
}
