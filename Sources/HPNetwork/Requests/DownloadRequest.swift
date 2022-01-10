import Foundation

public protocol DownloadRequest: NetworkRequest where Output == URL {

	func convertResponse(url: URL, response: URLResponse) throws -> Output
	func convertError(error: URLError, url: URL, response: URLResponse) -> Error

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

	func convertError(error: URLError, url: URL, response: URLResponse) -> Error {
		error
	}

	@discardableResult func response(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
		let urlRequest = try urlRequest()
		let startTime = DispatchTime.now()
		let result = try await urlSession.hp_download(for: urlRequest, delegate: delegate)
		let networkingEndTime = DispatchTime.now()
		let convertedResult = try downloadTaskResult(url: result.0, response: result.1)
		let processingEndTime = DispatchTime.now()
		let elapsedTime = calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
        return NetworkResponse(output: convertedResult, response: result.1, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
	}

	@discardableResult func result(delegate: URLSessionDataDelegate? = nil) async -> Result<NetworkResponse<Output>, Error> {
		do {
			let result = try await response(delegate: delegate)
			return .success(result)
		} catch {
			return .failure(error)
		}
	}

	func schedule(delegate: URLSessionDataDelegate? = nil, completion: @escaping (Result<NetworkResponse<Output>, Error>) -> Void) -> Task<(), Never> {
		Task {
			let result = await result(delegate: delegate)
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

}
