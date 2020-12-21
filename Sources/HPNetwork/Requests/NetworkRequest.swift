import Foundation

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

	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error {
		error
	}

}

// MARK: - Raw Data

public extension NetworkRequest where Output == Data {

	func convertResponse(response: NetworkResponse) throws -> Output {
		response.data
	}

}
