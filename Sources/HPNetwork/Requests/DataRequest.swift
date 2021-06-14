import Foundation

public protocol DataRequest: NetworkRequest {

	func convertResponse(data: Data, response: URLResponse) throws -> Output
	func convertError(error: Error, data: Data, response: URLResponse) -> Error

}

extension DataRequest {

	func dataTaskResult(data: Data, response: URLResponse) throws -> Output {
		if let error = response.urlError() {
			throw convertError(error: error, data: data, response: response)
		} else {
			return try convertResponse(data: data, response: response)
		}
	}

}

// MARK: - Scheduling and Convenience

public extension DataRequest {

	func convertError(_ error: Error, data: Data, response: URLResponse) -> Error {
		error
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	@discardableResult func schedule(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
		let urlRequest = try makeURLRequest()
		let startTime = DispatchTime.now()
		let result = try await urlSession.data(for: urlRequest, delegate: delegate)
		let networkingEndTime = DispatchTime.now()
		let convertedResult = try dataTaskResult(data: result.0, response: result.1)
		let processingEndTime = DispatchTime.now()
		let elapsedTime = calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
		return NetworkResponse(output: convertedResult, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
	}

}

// MARK: - Raw Data

public extension DataRequest where Output == Data {

	func convertResponse(data: Data, response: URLResponse) throws -> Output {
		data
	}

}
