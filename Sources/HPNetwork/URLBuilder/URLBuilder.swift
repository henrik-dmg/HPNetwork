import Foundation

public struct URLBuilder {

	// MARK: - Properties

    private let scheme: String
    private let host: String
    private let path: String
    private let queryItems: [URLQueryItem]

	// MARK: - Init

	@available(*, deprecated, message: "Use URLBuilder.build(_:) or URLBuilder.buildThrowing(_:) instead")
    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
        self.path = String()
        self.queryItems = []
    }

    private init(scheme: String = "https", host: String, path: String, queryItems: [URLQueryItem]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }

	public static func build(@URLComponentsBuilder block: () -> [URLBuildable?]) -> URL? {
		URL.build(block: block)
	}

	public static func buildThrowing(@URLComponentsBuilder block: () -> [URLBuildable?]) throws -> URL {
		try URL.buildThrowing(block: block)
	}

	// MARK: - Path Components

    public func addingPathComponent(_ component: String?) -> URLBuilder {
        guard let component = component else {
            return self
        }

        return URLBuilder(
            scheme: scheme,
            host: host,
            path: path + "/\(component)",
            queryItems: queryItems
        )
    }

	// MARK: - Numbers

    public func addingQueryItem(name: String, value: Double?, digits: Int = 2) -> URLBuilder {
        guard let value = value else {
            return self
        }

        let formattedString = String(format: "%.\(digits)f", value)

        return URLBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: formattedString)]
        )
    }

	// MARK: - Arrays

	public func addingQueryItem(name: String, value: [QueryStringConvertible?]?) -> URLBuilder {
		guard let value = value, !value.isEmpty else {
			return self
		}

		let itemsString = value.compactMap { $0?.queryItemRepresentation }.joined(separator: ",")

		return URLBuilder(
			scheme: scheme,
			host: host,
			path: path,
			queryItems: queryItems + [URLQueryItem(name: name, value: itemsString)]
		)
	}

	// MARK: - QueryStringConvertible

	public func addingQueryItem(name: String, value: QueryStringConvertible?) -> URLBuilder {
		guard let value = value else {
			return self
		}

		return URLBuilder(
			scheme: scheme,
			host: host,
			path: path,
			queryItems: queryItems + [URLQueryItem(name: name, value: value.queryItemRepresentation)]
		)
	}

	// MARK: - Building

    public func build() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
		components.path = path
		components.queryItems = queryItems.nilIfEmpty()

        return components.url
    }

	public func buildThrowing() throws -> URL {
		guard let url = build() else {
			throw NSError.urlBuilderFailed
		}
		return url
	}

}

private extension Array {

	func nilIfEmpty() -> Self? {
		isEmpty ? nil : self
	}

}
