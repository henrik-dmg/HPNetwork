import Foundation

public protocol DownloadRequest: NetworkRequest where Output == URL {

	func convertResponse(response: DownloadResponse) throws -> Output
	func convertError(_ error: Error, url: URL?, response: URLResponse?) -> Error

}

extension DownloadRequest {

	func convertResponse(response: DownloadResponse) throws -> Output {
		response.url
	}

	func convertError(_ error: Error, url: URL?, response: URLResponse?) -> Error {
		error
	}

}

public extension DownloadRequest {

	@discardableResult
	func schedule(on network: Network = .shared, progressHandler: ProgressHandler? = nil, completion: @escaping Completion) -> NetworkTask {
		network.schedule(request: self, progressHandler: progressHandler, completion: completion)
	}

	func scheduleSynchronously(on network: Network = .shared, progressHandler: ProgressHandler? = nil) -> RequestResult {
		network.scheduleSynchronously(request: self, progressHandler: progressHandler)
	}

}
