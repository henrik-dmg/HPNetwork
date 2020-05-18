import Foundation

public class NetworkTask: NSObject {

    private var task: URLSessionTask?
    private var cancelled = false
    private let queue = DispatchQueue(label: "com.henrikpanhans.NetworkTask", qos: .utility)

    public init(task: URLSessionTask? = nil, cancelled: Bool = false) {
        self.task = task
        self.cancelled = cancelled
    }

    public func cancel() {
        queue.sync {
            cancelled = true
            // If we already have a task cancel it
            if let task = task {
                task.cancel()
            }
        }
    }

    func set(_ task: URLSessionTask) {
        queue.sync {
            self.task = task
            // If we've cancelled the request before the task was set, let's cancel now
            if cancelled {
                task.cancel()
            }
        }
    }

}
