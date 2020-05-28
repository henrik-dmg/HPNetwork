import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class Network: NSObject {

    public static let shared = Network()
    private let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .userInitiated, attributes: .concurrent)


    @discardableResult
    public func dataTask<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()

        #if os(iOS) || os(tvOS)
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            let session = URLSession.shared

            guard let urlRequest = request.urlRequest() else {
                completion(.failure(NSError(description: "Failed to create URLRequest")))
                return
            }

            let task = session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<T.Output, Error>

                if let error = error {
                    result = .failure(error)
                } else if let error = Network.error(from: response) {
                    result = .failure(error)
                } else if let data = data, let httpResponse = response as? HTTPURLResponse {
                    do {
                        let response = NetworkResponse(data: data, httpResponse: httpResponse)
                        let output = try request.convertResponse(response: response)
                        result = .success(output)
                    } catch let error {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NSError.unknown)
                }

                DispatchQueue.main.async {
                    completion(result)

                    #if os(iOS) || os(tvOS)
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    #endif
                }
            }

            task.resume()

            // Asyncronously set the real task inside the network task.
            // Note: This may happen after the NetworkTask has been cancelled but the NetworkTask object already handles this
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
        let uploadTask = NetworkTask()

        #if os(iOS) || os(tvOS)
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async {
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)

            guard let urlRequest = request.urlRequest() else {
                completion(.failure(NSError(description: "Failed to create URLRequest")))
                return
            }

            let task = session.uploadTask(with: urlRequest, from: data) { data, response, error in
                let result: Result<T.Output, Error>

                if let error = error {
                    result = .failure(error)
                } else if let error = Network.error(from: response) {
                    result = .failure(error)
                } else if let data = data, let httpResponse = response as? HTTPURLResponse {
                    do {
                        let response = NetworkResponse(data: data, httpResponse: httpResponse)
                        let output = try request.convertResponse(response: response)
                        result = .success(output)
                    } catch let error {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NSError.unknown)
                }

                DispatchQueue.main.async {
                    completion(result)

                    #if os(iOS) || os(tvOS)
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    #endif
                }
            }

            task.resume()

            // Asyncronously set the real task inside the network task.
            // Note: This may happen after the NetworkTask has been cancelled but the NetworkTask object already handles this
            uploadTask.set(task)
        }

        return uploadTask
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
                completion(.failure(NSError(description: "Failed to create URLRequest")))
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

                DispatchQueue.main.async {
                    completion(result)

                    #if os(iOS) || os(tvOS)
                    UIApplication.shared.endBackgroundTask(backgroundTaskID)
                    #endif
                }
            }

            task.resume()

            // Asyncronously set the real task inside the network task.
            // Note: This may happen after the NetworkTask has been cancelled but the NetworkTask object already handles this
            downloadTask.set(task)
        }

        return downloadTask
    }

    // MARK: - Helpers

    private static func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        switch response.statusCode {
        case 200...299:
            return nil
        case 404:
            return NSError(code: 404, description: "URL not found")
        case 429:
            return NSError(code: 429, description: "Too many requests")
        case 401:
            return NSError(code: 401, description: "Unauthorized request")
        default:
            return NSError(code: response.statusCode, description: "Networking returned with HTTP code \(response.statusCode)")
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
