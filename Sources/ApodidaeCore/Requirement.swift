public enum Requirement {
    case tag(String)
    case branch(String)
    case revision(String)

    var packageString: String {
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
