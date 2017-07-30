import Foundation

extension Date {
    static let isoFormatter: DateFormatter = {
        let isoForm = DateFormatter()
        isoForm.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return isoForm
    }()

    public var iso: String {
        return Date.isoFormatter.string(from: self)
    }
}
