extension Dictionary where Key == String {
    var urlEncoded: String {
        let params = self
            .mapValues { String(describing: $0) }
            .map { (key: String, value: String) in (key: key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) }

        // TODO: Uniqueing Dictionary init doesn't want to work at this point :/
        var dict = Dictionary<String, String>()
        for (key, value) in params {
            dict[key] = value
        }

        return dict
            .map { (key: String, value: String) in return "\(key)=\(value)" }
            .joined(separator: "&")
    }
}
