import Foundation

public protocol DataRequest: NetworkRequest {

	func convertResponse(response: DataResponse) throws -> Output
	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error

}

public extension DataRequest  {

	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error {
		error
	}

}

public extension DataRequest {

	@discardableResult
	func schedule(on network: Network = .shared, progressHandler: ProgressHandler? = nil, completion: @escaping Completion) -> NetworkTask {
		network.schedule(request: self, progressHandler: progressHandler, completion: completion)
	}

	func scheduleSynchronously(on network: Network = .shared, progressHandler: ProgressHandler? = nil) -> RequestResult {
		network.scheduleSynchronously(request: self, progressHandler: progressHandler)
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	@discardableResult
	func schedule(on network: Network = .shared, delegate: URLSessionDataDelegate? = nil) async throws -> Network.Response<Output> {
		try await network.schedule(request: self, delegate: delegate)
	}

}

// MARK: - Raw Data

public extension DataRequest where Output == Data {

	func convertResponse(response: DataResponse) throws -> Output {
		response.data
	}

}
