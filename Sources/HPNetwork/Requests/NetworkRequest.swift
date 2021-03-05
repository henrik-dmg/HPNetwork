import Foundation

// MARK: - NetworkRequest

public protocol NetworkRequest {

	associatedtype Output

	typealias RequestResult = Result<Output, Error>
	typealias Completion = (RequestResult) -> Void

	var finishingQueue: DispatchQueue { get }
	var url: URL? { get }
	var httpBody: Data? { get }
	var urlSession: URLSession { get }

	var headerFields: [NetworkRequestHeaderField]? { get }
	var requestMethod: NetworkRequestMethod { get }
	var authentication: NetworkRequestAuthentication? { get }

	func convertResponse(response: NetworkResponse) throws -> Output
	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error

}

extension NetworkRequest {

	func makeURLRequest() throws -> URLRequest {
		guard let url = url else {
			throw NSError.failedToCreateRequest.withFailureReason("The URL instance to create the request is nil")
		}

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

}

// MARK: - Raw Data

public extension NetworkRequest where Output == Data {

	func convertResponse(response: NetworkResponse) throws -> Output {
		response.data
	}

}
