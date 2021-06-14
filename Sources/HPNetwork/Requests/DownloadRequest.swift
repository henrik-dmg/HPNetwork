import Foundation

public protocol DownloadRequest: NetworkRequest where Output == URL {

	func convertResponse(url: URL, response: URLResponse) throws -> Output
	func convertError(error: Error, url: URL, response: URLResponse) -> Error

}

extension DownloadRequest {

	func downloadTaskResult(url: URL, response: URLResponse) throws -> Output {
		if let error = response.urlError() {
			throw convertError(error: error, url: url, response: response)
		} else {
			return try convertResponse(url: url, response: response)
		}
	}

}

// MARK: - Scheduling and Convenience

public extension DownloadRequest {

	func convertResponse(url: URL, response: URLResponse) throws -> Output {
		url
	}

	func convertError(error: Error, url: URL, response: URLResponse) -> Error {
		error
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	@discardableResult func schedule(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
		let urlRequest = try makeURLRequest()
		let startTime = DispatchTime.now()
		let result = try await urlSession.download(for: urlRequest, delegate: delegate)
		let networkingEndTime = DispatchTime.now()
		let convertedResult = try downloadTaskResult(url: result.0, response: result.1)
		let processingEndTime = DispatchTime.now()
		let elapsedTime = calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
		return NetworkResponse(output: convertedResult, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
	}

}
