import Foundation

public protocol URLBuildable {

	func modifyURLComponents(_ components: inout URLComponents)

}

public struct Scheme: URLBuildable {

	let scheme: String

	public init(_ scheme: String) {
		self.scheme = scheme
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.scheme = scheme
	}

}

public struct Host: URLBuildable {

	let host: String

	public init(_ host: String) {
		self.host = host
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.host = host
	}

}

public struct Path: URLBuildable {

	let path: String

	public init(_ path: String) {
		self.path = path
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.path = path
	}

}

public struct PathComponent: URLBuildable {

	let pathComponent: String

	public init(_ pathComponent: String) {
		self.pathComponent = pathComponent
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		var pathComponents = components.path.components(separatedBy: "/")
		pathComponents.append(pathComponent)
		components.path = pathComponents.joined(separator: "/")
	}

}

public struct QueryItem: URLBuildable {

	let name: String
	let value: QueryStringConvertible?

	public init(name: String, value: QueryStringConvertible?) {
		self.name = name
		self.value = value
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		guard let value = value else {
			return
		}
		components.queryItems?.append(URLQueryItem(name: name, value: value.queryItemRepresentation))
	}

}
