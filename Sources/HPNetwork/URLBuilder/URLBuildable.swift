import Foundation

protocol URLBuildable {

	func modifyURLComponents(_ components: inout URLComponents)

}

@resultBuilder struct URLBuilderNew {

	static func buildBlock(_ components: URLBuildable...) -> [URLBuildable] {
		components
	}

	static func buildEither(first component: [URLBuildable]) -> [URLBuildable] {
		component
	}

	static func buildEither(second component: [URLBuildable]) -> [URLBuildable] {
		component
	}

	static func buildOptional(_ component: [URLBuildable?]) -> [URLBuildable] {
		component.compactMap { $0 }
	}

}

extension URL {

	static func build(@URLBuilderNew block: () -> [URLBuildable]) -> URL? {
		var components = URLComponents()
		let blocks = block()
		blocks.forEach { $0.modifyURLComponents(&components) }
		print(components)
		return components.url
	}

}

struct Scheme: URLBuildable {

	let scheme: String

	init(_ scheme: String) {
		self.scheme = scheme
	}

	func modifyURLComponents(_ components: inout URLComponents) {
		components.scheme = scheme
	}

}

struct Host: URLBuildable {

	let host: String

	init(_ host: String) {
		self.host = host
	}

	func modifyURLComponents(_ components: inout URLComponents) {
		components.host = host
	}

}

struct Path: URLBuildable {

	let path: String

	init(_ path: String) {
		self.path = path
	}

	func modifyURLComponents(_ components: inout URLComponents) {
		components.path = path
	}

}

struct PathComponent: URLBuildable {

	let pathComponent: String

	init(_ pathComponent: String) {
		self.pathComponent = pathComponent
	}

	func modifyURLComponents(_ components: inout URLComponents) {
		var pathComponents = components.path.components(separatedBy: "/")
		pathComponents.append(pathComponent)
		components.path = pathComponents.joined(separator: "/")
	}

}

struct QueryItem: URLBuildable {

	let name: String
	let value: QueryStringConvertible?

	func modifyURLComponents(_ components: inout URLComponents) {
		guard let value = value else {
			return
		}
		components.queryItems?.append(URLQueryItem(name: name, value: value.queryItemRepresentation))
	}

}
