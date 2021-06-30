import Foundation

@resultBuilder public struct URLComponentsBuilder {

	public static func buildBlock(_ components: URLBuildable?...) -> [URLBuildable?] {
		components
	}

	public static func buildEither(first component: [URLBuildable?]?) -> [URLBuildable?] {
		component ?? []
	}

	public static func buildEither(second component: [URLBuildable?]?) -> [URLBuildable?] {
		component ?? []
	}

	public static func buildOptional(_ component: [URLBuildable?]?) -> [URLBuildable?] {
		component ?? []
	}

	public static func buildArray(_ components: [[URLBuildable?]]) -> [URLBuildable?] {
		components.reduce([URLBuildable?]()) { partialResult, array in
			var new = partialResult
			new.append(contentsOf: array)
			return new
		}
	}

}

public extension URL {

	static func build(@URLComponentsBuilder block: () -> [URLBuildable?]) -> URL? {
		var components = URLComponents()
		components.scheme = "https"
		let blocks = block().compactMap { $0 }
		blocks.forEach { $0.modifyURLComponents(&components) }
		return components.url
	}

	static func buildThrowing(@URLComponentsBuilder block: () -> [URLBuildable?]) throws -> URL {
		guard let url = build(block: block) else {
			throw NSError.urlBuilderFailed
		}
		return url
	}

}
