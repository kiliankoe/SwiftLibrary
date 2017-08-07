import Foundation

func confirm(_ text: String, default: Bool) -> Bool {
    let suffix = `default` ? "[Yn]" : "[yN]"

    while true {
        print("\(text) \(suffix)")
        guard let input = readLine(strippingNewline: true) else { continue }
        switch input.lowercased() {
        case "": return `default`
        case "y", "yes": return true
        case "n", "no": return false
        default:
            print("Invalid input, expected 'y', 'yes', 'n' or 'no'.")
        }
    }
}
