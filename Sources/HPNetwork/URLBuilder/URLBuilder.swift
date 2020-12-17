import Foundation

public struct URLBuilder {

	// MARK: - Properties

    private let scheme: String
    private let host: String
    private let path: String
    private let queryItems: [URLQueryItem]

	// MARK: - Init

    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
        self.path = String()
        self.queryItems = []
    }

    internal init(scheme: String = "https", host: String, path: String, queryItems: [URLQueryItem]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
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

    public func addingQueryItem(_ item: Double?, digits: Int, name: String) -> URLBuilder {
        guard let item = item else {
            return self
        }

        let formattedString = String(format: "%.\(digits)f", item)

        return URLBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: formattedString)]
        )
    }

    public func addingQueryItem(_ item: Int?, name: String) -> URLBuilder {
        guard let item = item else {
            return self
        }

        return URLBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: "\(item)")]
        )
    }

	// MARK: - Arrays

    public func addingQueryItem(_ items: [QueryStringConvertible?], name: String) -> URLBuilder {
        guard !items.isEmpty else {
            return self
        }
    
		let itemsString = items.compactMap { $0?.queryItemRepresentation }.joined(separator: ",")

        return URLBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: itemsString)]
        )
    }

	public func addingQueryItem(_ items: [QueryStringConvertible]?, name: String) -> URLBuilder {
		guard let items = items, !items.isEmpty else {
			return self
		}

		return self.addingQueryItem(items, name: name)
	}

	public func addingQueryItem(_ items: [QueryStringConvertible?]?, name: String) -> URLBuilder {
		guard let items = items, !items.isEmpty else {
			return self
		}

		return self.addingQueryItem(items, name: name)
	}

	// MARK: - QueryStringConvertible

	public func addingQueryItem(_ item: QueryStringConvertible?, name: String) -> URLBuilder {
		guard let item = item else {
			return self
		}

		return URLBuilder(
			scheme: scheme,
			host: host,
			path: path,
			queryItems: queryItems + [URLQueryItem(name: name, value: item.queryItemRepresentation)]
		)
	}

	// MARK: - Building

    public func build() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
		components.path = path
        components.queryItems = queryItems

        return components.url
    }

}
