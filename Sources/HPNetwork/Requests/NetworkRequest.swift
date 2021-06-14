import Foundation

// MARK: - NetworkRequest

public protocol NetworkRequest {

	/// The expected output type returned in the network request
	associatedtype Output

	var httpBody: Data? { get }
	var urlSession: URLSession { get }

	var headerFields: [NetworkRequestHeaderField]? { get }
	/// The request method that will be used
	var requestMethod: NetworkRequestMethod { get }
	var authentication: NetworkRequestAuthentication? { get }

	func makeURL() throws -> URL

}

extension NetworkRequest {

	func makeURLRequest() throws -> URLRequest {
		let url = try makeURL()

		var request = URLRequest(url: url)
		request.httpMethod = requestMethod.rawValue
		request.httpBody = httpBody
		if let auth = authentication {
			guard let field = auth.headerField else {
				throw NSError.failedToCreateRequest.withFailureReason("Could not create authorisation header field: \(auth)")
			}
			request.addHeaderField(field)
		}
		headerFields?.forEach {
			request.addHeaderField($0)
		}
		return request
	}

	func calculateElapsedTime(startTime: DispatchTime, networkingEndTime: DispatchTime, processingEndTime: DispatchTime) -> (TimeInterval, TimeInterval) {
		let networkingTime = Double(networkingEndTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
		let processingTime = Double(processingEndTime.uptimeNanoseconds - networkingEndTime.uptimeNanoseconds)

		// converting nanoseconds to seconds
		return (networkingTime / 1e9, processingTime / 1e9)
	}

}

// MARK: - Sensible Defaults

public extension NetworkRequest {

	var httpBody: Data? { nil }

	var urlSession: URLSession { .shared }

	var headerFields: [NetworkRequestHeaderField]? { nil }

	var authentication: NetworkRequestAuthentication? { nil }

}
