import Foundation

// MARK: - NetworkRequest

public protocol NetworkRequest {

	/// The expected output type returned in the network request
	associatedtype Output

	/// A result containing either the specified output type or an error
	typealias RequestResult = Result<Output, Error>

	/// A result containing either the specified output type or an error
	typealias RequestResultIncludingElapsedTime = (Result<Output, Error>, TimeInterval, TimeInterval)

	/// A callback which includes the result of the networking operation
	/// - Parameters:
	///   - result: A result containing either the specified output type or an error
	typealias Completion = (_ result: RequestResult) -> Void

	/// A callback which includes the result of the networking operation and elapsed times. The first `TimeInterval` is the seconds which
	/// the networking itself took and the second is the processing time in seconds
	/// - Parameters:
	///   - result: A result containing either the specified output type or an error
	///   - networkingTime: the time in seconds which the networking itself took
	///   - processingTime: the time in seconds which the processing took
	typealias CompletionWithElapsedTime = (_ result: RequestResult, _ networkingTime: TimeInterval, _ processingTime: TimeInterval) -> Void

	var finishingQueue: DispatchQueue { get }
	var httpBody: Data? { get }
	var urlSession: URLSession { get }

	var headerFields: [NetworkRequestHeaderField]? { get }
	/// The request method that will be used
	var requestMethod: NetworkRequestMethod { get }
	var authentication: NetworkRequestAuthentication? { get }

	func makeURL() throws -> URL

	func convertResponse(response: NetworkResponse) throws -> Output
	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error

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

}

// MARK: - Sensible Defaults

public extension NetworkRequest {

	var finishingQueue: DispatchQueue { .main }

	var httpBody: Data? { nil }

	var urlSession: URLSession { .shared }

	var headerFields: [NetworkRequestHeaderField]? { nil }

	var authentication: NetworkRequestAuthentication? { nil }

	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error {
		error
	}

	@discardableResult
	func schedule(on network: Network = .shared, progressHandler: ProgressHandler? = nil, completion: @escaping Completion) -> NetworkTask {
		network.schedule(request: self, progressHandler: progressHandler, completion: completion)
	}

	func scheduleSynchronously(on network: Network = .shared, progressHandler: ProgressHandler? = nil) -> RequestResult {
		network.scheduleSynchronously(request: self, progressHandler: progressHandler)
	}

}

// MARK: - Raw Data

public extension NetworkRequest where Output == Data {

	func convertResponse(response: NetworkResponse) throws -> Output {
		response.data
	}

}
