import Foundation

public protocol URLBuildable {

	func modifyURLComponents(_ components: inout URLComponents)

}

public struct Scheme: URLBuildable {

	let scheme: String

	public init?(_ scheme: String?) {
		guard let scheme = scheme else {
			return nil
		}
		self.scheme = scheme
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.scheme = scheme
	}

}

public struct Host: URLBuildable {

	let host: String

	public init?(_ host: String?) {
		guard let host = host else {
			return nil
		}
		self.host = host
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.host = host
	}

}

public struct Path: URLBuildable {

	let path: String

	public init?(_ path: String?) {
		guard let path = path else {
			return nil
		}
		self.path = path
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		components.path = path
	}

}

public struct PathComponent: URLBuildable {

	let pathComponent: String

	public init?(_ pathComponent: String?) {
		guard let pathComponent = pathComponent else {
			return nil
		}
		self.pathComponent = pathComponent
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		var pathComponents = components.path.components(separatedBy: "/")
		pathComponents.append(pathComponent)
		components.path = pathComponents.joined(separator: "/")
	}

}

public struct ForEach: URLBuildable {

	let blocks: [URLBuildable?]

	public init?<T>(_ data: [T]?, @URLComponentsBuilder block: (T) -> [URLBuildable?]) {
		guard let data = data, !data.isEmpty else {
			return nil
		}

		let blocks = data.map { block($0) }
		self.blocks = blocks.reduce([URLBuildable?]()) { prev, arr in
			var new = prev
			new.append(contentsOf: arr)
			return new
		}
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		blocks.forEach {
			$0?.modifyURLComponents(&components)
		}
	}

}

public struct QueryItem: URLBuildable {

	let name: String
	let string: String

	public init?(name: String, value: QueryStringConvertible?) {
		guard let value = value else {
			return nil
		}
		self.name = name
		self.string = value.queryItemRepresentation
	}

	public init?(name: String, value: Double?, digits: Int) {
		guard let value = value else {
			return nil
		}
		self.name = name
		self.string = String(format: "%.\(digits)f", value)
	}

	public init?(name: String, value: [QueryStringConvertible?]?) {
		guard let value = value, !value.isEmpty else {
			return nil
		}
		self.name = name
		self.string = value.compactMap { $0?.queryItemRepresentation }.joined(separator: ",")
	}

	public func modifyURLComponents(_ components: inout URLComponents) {
		let item = URLQueryItem(name: name, value: string)
		if components.queryItems == nil {
			components.queryItems = [item]
		} else {
			components.queryItems?.append(item)
		}
	}

}
