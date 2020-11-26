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
	var headerFields: [NetworkRequestHeaderField]? { get }
	var httpBody: Data? { get }
    var requestMethod: NetworkRequestMethod { get }
    var authentication: NetworkRequestAuthentication? { get }
    var urlSession: URLSession { get }

    func convertResponse(response: NetworkResponse) throws -> Output
	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error

}

// Some sensible defaults

public extension NetworkRequest {

	var headerFields: [NetworkRequestHeaderField]? { nil }

	var httpBody: Data? { nil }

    var finishingQueue: DispatchQueue { .main }

    var authentication: NetworkRequestAuthentication? { nil }

    var urlSession: URLSession { .shared }

	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error {
		error
	}

}

// MARK: - Convenience

#if os(iOS)
import UIKit
#endif

public extension NetworkRequest {

    func urlRequest() -> URLRequest? {
        guard let url = url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
		request.httpBody = httpBody
		if let auth = authentication {
			request.addHeaderField(auth.headerField)
		}
        headerFields?.forEach {
			request.addHeaderField($0)
		}
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

            #if os(iOS)
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
			let convertedError = convertError(error, data: data, response: response)
            result = .failure(convertedError)
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
