import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class Network {

    public static let shared = Network()
    private let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .userInitiated, attributes: .concurrent)

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    public func send<T: NetworkRequest>(
        _ request: T,
        completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()

        #if canImport(UIKit)
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async { [weak self] in
            guard let session = self?.session else {
                completion(.failure(NSError(description: "No session found")))
                return
            }

            guard let urlRequest = request.urlRequest() else {
                completion(.failure(NSError(description: "Failed to create URLRequest")))
                return
            }

            let task = session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<T.Output, Error>

                if let error = error {
                    result = .failure(error)
                } else if let error = Network.error(from: response, with: request) {
                    result = .failure(error)
                } else if let data = data, let httpResponse = response as? HTTPURLResponse {
                    do {
                        let response = NetworkResponse(data: data, httpResponse: httpResponse)
                        let input = try request.convertInput(response: response)
                        let output = try request.convertResponse(input: input, response: response)
                        result = .success(output)
                    } catch let error {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NSError.unknown)
                }

                DispatchQueue.main.async {
                    completion(result)

                    #if canImport(UIKit)
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

    // MARK: - Helpers

    private static func error<T: NetworkRequest>(from response: URLResponse?, with request: T) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = response.statusCode
        if statusCode >= 200 && statusCode <= 299 {
            return nil
        } else {
            return NSError(code: statusCode, description: "Networking returned with HTTP code \(statusCode)")
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
