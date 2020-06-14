import Foundation

/**
 A protocol to wrap request objects. This gives us a better API over URLRequest.
 */
public protocol NetworkRequest {

    associatedtype Output

    /**
     Generates a URLRequest from the request. This will be run on a background thread so model parsing is allowed.
     */
    func urlRequest() -> URLRequest?

    var finishingQueue: DispatchQueue { get }
    var url: URL? { get }
    var requestMethod: NetworkRequestMethod { get }
    var authentication: NetworkRequestAuthentication? { get }

    func convertResponse(response: NetworkResponse) throws -> Output

}

// MARK: - Convenience Extensions

public extension NetworkRequest {

    func urlRequest() -> URLRequest? {
        guard let url = url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.setValue(authentication?.headerString, forHTTPHeaderField: "Authorization")
        return request
    }

    internal func finish(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        backgroundTask: BackgroundTaskWrapper,
        finishingQueue: DispatchQueue,
        completion: @escaping (Result<Output, Error>) -> Void)
    {
        let result = taskResult(data: data, response: response, error: error)

        finishingQueue.async {
            completion(result)

            #if os(iOS) || os(tvOS)
            guard let id = backgroundTask.backgroundTaskID else {
                return
            }
            UIApplication.shared.endBackgroundTask(id)
            #endif
        }
    }

    internal func taskResult(data: Data?, response: URLResponse?, error: Error?) -> Result<Output, Error> {
        let result: Result<Output, Error>

        if let error = error {
            result = .failure(error)
        } else if let error = Network.error(from: response) {
            result = .failure(error)
        } else if let data = data, let httpResponse = response as? HTTPURLResponse {
            do {
                let response = NetworkResponse(data: data, httpResponse: httpResponse)
                let output = try convertResponse(response: response)
                result = .success(output)
            } catch let error {
                result = .failure(error)
            }
        } else {
            result = .failure(NSError.unknown)
        }

        return result
    }

}

extension NetworkRequest where Output == Data {

    public func convertResponse(response: NetworkResponse) throws -> Output {
        response.data
    }

}

extension NetworkRequest where Output: Decodable {

    public func convertResponse(response: NetworkResponse) throws -> Output {
        do {
            return try JSONDecoder().decode(Output.self, from: response.data)
        } catch let error as NSError {
            throw error.injectJSON(response.data)
        }
    }

}

#if canImport(UIKit)
import UIKit

extension NetworkRequest where Output == UIImage {

    public func convertResponse(response: NetworkResponse) throws -> UIImage {
        guard let image = UIImage(data: response.data) else {
            throw NSError.imageError
        }
        return image
    }
    
}

#endif

#if canImport(AppKit)
import AppKit

extension NetworkRequest where Output == NSImage {

    public func convertResponse(response: NetworkResponse) throws -> NSImage {
        guard let image = NSImage(data: response.data) else {
            throw NSError.imageError
        }
        return image
    }

}

#endif

public enum NetworkRequestMethod: String {

    case get = "GET"
    case post = "POST"
    case head = "HEAD"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"

}
