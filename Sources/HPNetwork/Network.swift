import Foundation
#if canImport(UIKit)
import UIKit
#endif

public class Network {

    public static let shared = Network()
    private let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .userInitiated, attributes: .concurrent)

    enum NetworkError: Error {
        case noDataOrError
    }

    struct StatusCodeError: LocalizedError {
        let code: Int

        var errorDescription: String? {
            return "An error occurred communicating with the server. Please try again."
        }
    }

    /**
     The session that the app uses. Since it uses delegate: self, it must be declared lazy. You should never change this.
     */
    let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - API
    /**
     Sends a data request and parses the result into a model. To specify the model type, you'll need to include the type in your completion block.
     For instance:
     ```Network.shared.send(request) { result: Result<MyModel, Error> in ```
     */
    @discardableResult
    public func send<T: NetworkRequestable>(
        _ request: T,
        completion: @escaping (Result<T.ResultType, Error>) -> Void) -> NetworkTask
    {
        // Create a network task to immediately return
        let networkTask = NetworkTask()

        #if canImport(UIKit)
        let backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif

        // Go to a background queue as request.urlRequest() may do json parsing
        queue.async { [weak self] in
            guard let `self` = self else {
                completion(.failure(NetworkError.noDataOrError))
                return
            }

            let urlRequest = request.urlRequest()

            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<T.ResultType, Error>

                if let error = error {
                    result = .failure(error)
                } else if let error = Network.error(from: response, with: request) {
                    result = .failure(error)
                } else if let data = data {
                    do {
                        let model = try JSONDecoder().decode(T.ResultType.self, from: data)
                        result = .success(model)
                    } catch let error {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NetworkError.noDataOrError)
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

    // MARK: Helpers
    private static func error<T: NetworkRequestable>(from response: URLResponse?, with request: T) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = response.statusCode
        if statusCode >= 200 && statusCode <= 299 {
            return nil
        } else {
            return StatusCodeError(code: statusCode)
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
