import Foundation

public protocol DownloadRequest: Request where Output == URL {

	func convertError(_ error: Error, response: URLResponse?) -> Error

}

// MARK: - Convenience

public extension DownloadRequest {

	func convertError(_ error: Error, response: URLResponse?) -> Error {
		error
	}

}
