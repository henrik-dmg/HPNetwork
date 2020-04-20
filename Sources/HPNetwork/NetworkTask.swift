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

public class DownloadTask: NetworkTask, URLSessionDelegate {

    public weak var delegate: DownloadTaskDelegate?

    public init(task: URLSessionTask? = nil, cancelled: Bool = false, delegate: DownloadTaskDelegate? = nil) {
        self.delegate = delegate
        super.init(task: task, cancelled: cancelled)
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
         // Gives you the URLSessionDownloadTask that is being executed
         // along with the total file length - totalBytesExpectedToWrite
         // and the current amount of data that has received up to this point - totalBytesWritten
        print(totalBytesWritten, totalBytesExpectedToWrite)

        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        delegate?.downloadProgressUpdate(session, downloadTask: downloadTask, progress: progress)
    }

}

public protocol DownloadTaskDelegate: class {
    func downloadProgressUpdate(_ session: URLSession, downloadTask: URLSessionDownloadTask, progress: Double)
}
