import Foundation

func run(cmd: String, args: [String]) {
    let task = Process()
    task.launchPath = cmd
    task.arguments = args
    task.launch()
}
