import Foundation

extension String {
    var urlEscaped: String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
