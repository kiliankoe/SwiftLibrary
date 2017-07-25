import Foundation

extension String {
    var urlHostEscaped: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
