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
            guard let task = request.makeDataTask(
                backgroundTask: backgroundWrapper,
                completion: completion)
            else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    // This really needs a refactor dude
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
            guard let task = request.makeUploadTask(
                data: data,
                backgroundTask: backgroundWrapper,
                completion: completion)
            else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    // This really needs a refactor dude
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
            guard let task = request.makeUploadTask(
                fileURL: fileURL,
                backgroundTask: backgroundWrapper,
                completion: completion)
            else {
                return
            }

            task.resume()
            networkTask.set(task)
        }

        return networkTask
    }

    // This really needs a refactor dude
    @discardableResult
    public func downloadTask<R: NetworkRequest>(
        _ request: R,
        completion: @escaping (Result<URL, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let downloadTask = NetworkTask()

        #if os(iOS) || os(tvOS)
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

            guard let urlRequest = request.urlRequest() else {
                completion(.failure(NSError.failedToCreate))
                return
            }

            let task = session.downloadTask(with: urlRequest) { url, response, error in
                let result: Result<URL, Error>

                if let error = error {
                    result = .failure(error)
                } else if let error = Network.error(from: response) {
                    result = .failure(error)
                } else if let url = url {
                    result = .success(url)
                } else {
                    result = .failure(NSError.unknown)
                }

                request.finishingQueue.async {
                    completion(result)

                    #if os(iOS) || os(tvOS)
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    #endif
                }
            }

            task.resume()
            downloadTask.set(task)
        }

        return downloadTask
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
