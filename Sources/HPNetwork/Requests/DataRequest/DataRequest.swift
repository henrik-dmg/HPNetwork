import Foundation

public protocol DataRequest: Request {

	func convertResponse(response: NetworkResponse) throws -> Output
	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error

}

// MARK: - Convenience

public extension DataRequest {

	func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error {
		error
	}

}

// MARK: - Raw Data

public extension DataRequest where Output == Data {

	func convertResponse(response: NetworkResponse) throws -> Output {
        response.data
    }

}

// MARK: - Images

#if canImport(UIKit)

import UIKit

public extension DataRequest where Output == UIImage {

	func convertResponse(response: NetworkResponse) throws -> UIImage {
		guard let image = UIImage(data: response.data) else {
			throw NSError.imageError
		}
		return image
	}

}

#elseif canImport(AppKit)

import AppKit

public extension DataRequest where Output == NSImage {

	func convertResponse(response: NetworkResponse) throws -> NSImage {
		guard let image = NSImage(data: response.data) else {
			throw NSError.imageError
		}
		return image
	}

}

#endif
