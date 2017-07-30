import Foundation

extension Dictionary where Key == String {
    var asJSON: Data? {
        return try? JSONSerialization.data(withJSONObject: self)
    }
}
