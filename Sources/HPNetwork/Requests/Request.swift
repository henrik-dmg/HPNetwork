import Foundation

public protocol Request {

	associatedtype Output

	/**
	 Generates a URLRequest from the request. This will be run on a background thread so model parsing is allowed.
	 */
	func urlRequest() -> URLRequest?

	var finishingQueue: DispatchQueue { get }
	var url: URL? { get }
	var headerFields: [RequestHeaderField]? { get }
	var httpBody: Data? { get }
	var requestMethod: RequestMethod { get }
	var authentication: RequestAuthentication? { get }
	var urlSession: URLSession { get }

}

// Some sensible defaults

public extension Request {

	var headerFields: [RequestHeaderField]? { nil }

	var httpBody: Data? { nil }

	var finishingQueue: DispatchQueue { .main }

	var authentication: RequestAuthentication? { nil }

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

}
