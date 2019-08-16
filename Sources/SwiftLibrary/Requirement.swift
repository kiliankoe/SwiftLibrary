public enum Requirement {
    case tag(String)
    case branch(String)
    case revision(String)

    public var packageString: String {
        switch self {
        case .tag(let version):
            return "from: \"\(version)\""
        case .branch(let branch):
            return ".branch(\"\(branch)\")"
        case .revision(let revision):
            return ".revision(\"\(revision)\")"
        }
    }
}

extension Requirement: Equatable {
    public static func == (lhs: Requirement, rhs: Requirement) -> Bool {
        switch (lhs, rhs) {
        case (.tag(let lhsv), .tag(let rhsv)): return lhsv == rhsv
        case (.branch(let lhsb), .branch(let rhsb)): return lhsb == rhsb
        case (.revision(let lhsr), .revision(let rhsr)): return lhsr == rhsr
        default: return false
        }
    }
}
