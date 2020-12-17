import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class Network {

	// MARK: - Properties

    public static let shared = Network()
	private let queue: DispatchQueue

	// MARK: - Init

	public init(queue: DispatchQueue) {
		self.queue = queue
	}

	convenience init() {
		let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .userInitiated, attributes: .concurrent)
		self.init(queue: queue)
	}

	// MARK: - Requests

    @discardableResult
    public func dataTask<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()
        let backgroundWrapper = BackgroundTaskWrapper()

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            guard let task = request.makeDataTask(backgroundTask: backgroundWrapper, completion: completion) else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    @discardableResult
    public func uploadTask<T: NetworkRequest>(
        _ request: T,
        data: Data?,
        completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()
        let backgroundWrapper = BackgroundTaskWrapper()

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            guard let task = request.makeUploadTask(data: data, backgroundTask: backgroundWrapper, completion: completion) else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    @discardableResult
    public func uploadTask<T: NetworkRequest>(
        _ request: T,
        fileURL: URL,
        completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()
        let backgroundWrapper = BackgroundTaskWrapper()

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            guard let task = request.makeUploadTask(fileURL: fileURL, backgroundTask: backgroundWrapper, completion: completion) else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    // This really needs a refactor dude
    @discardableResult
	public func downloadTask<R: DownloadRequest>(
		_ request: R,
		completion: @escaping (Result<R.Output, Error>) -> Void) -> NetworkTask
    {
		// Create a network task to immediately return
		let networkTask = NetworkTask()
		let backgroundWrapper = BackgroundTaskWrapper()

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
			guard let task = request.makeDownloadTask(backgroundTask: backgroundWrapper, completion: completion) else {
				return
			}

			task.resume()
			networkTask.set(task)
        }

        return networkTask
    }

    // MARK: - Helpers

    static func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        switch response.statusCode {
        case 200...299:
            return nil
        default:
            let errorCode = URLError.Code(rawValue: response.statusCode)
            return URLError(errorCode)
        }
    }

    // MARK: - File Handling

    private static func moveFile(from origin: URL, to destination: URL) throws {
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        try FileManager.default.moveItem(at: origin, to: destination)
    }

}
