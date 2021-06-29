import Foundation

/// A protocol that's used to handle regular network request where data is downloaded
public protocol DataRequest: NetworkRequest {

	/// Called by ``schedule(delegate:)`` once the networking has finished.
	///
	/// For more convenient handling of `Decodable` output types, use ``DecodableRequest``
	/// - Parameters:
	/// 	- data: The raw data returned by the networking
	/// 	- response: The network response
	/// - Returns: An instance of the specified output type
	func convertResponse(data: Data, response: URLResponse) throws -> Output

	/// Called by ``schedule(delegate:)`` if the networking has finished successfully but `response` indicates an error.
	/// Can be used to simply log errors or inspect them otherwise
	///
	/// The default implementation of this simply forwards the passed in error
	/// - Parameters:
	/// 	- error: The error that occured based on `response`
	///		- data: The raw data returned by the networking
	///		- response: The network response
	/// - Returns: The passed in or modified error
	func convertError(error: URLError, data: Data, response: URLResponse) -> Error

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

	func convertError(error: URLError, data: Data, response: URLResponse) -> Error {
		error
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	@discardableResult func schedule(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
		let urlRequest = try urlRequest()
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

	/// Called by ``schedule(delegate:)`` once the networking has finished.
	///
	/// - Parameters:
	/// 	- data: The raw data returned by the networking
	/// 	- response: The network response
	/// - Returns: The raw data returned by the networking
	func convertResponse(data: Data, response: URLResponse) throws -> Output {
		data
	}

}
