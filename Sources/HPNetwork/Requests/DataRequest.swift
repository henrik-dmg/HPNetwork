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

}

// MARK: - Raw Data

public extension DataRequest where Output == Data {

	func convertResponse(response: DataResponse) throws -> Output {
		response.data
	}

}
