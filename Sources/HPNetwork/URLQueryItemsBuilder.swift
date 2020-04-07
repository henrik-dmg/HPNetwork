import Foundation

public struct URLQueryItemsBuilder {

    private let scheme: String
    private let host: String
    private let path: String
    private let queryItems: [URLQueryItem]

    public init(scheme: String = "https", _ hostString: String) {
        self.scheme = scheme
        self.host = hostString
        self.path = String()
        self.queryItems = []
    }

    internal init(scheme: String = "https", host: String, path: String, queryItems: [URLQueryItem]) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
    }

    public func addingPathComponent(_ component: String) -> URLQueryItemsBuilder {
        let encodedString = component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
        return URLQueryItemsBuilder(
            scheme: scheme,
            host: host,
            path: path + "/\(encodedString)",
            queryItems: queryItems)
    }

    public func addingQueryItem(_ item: String, name: String) -> URLQueryItemsBuilder {
        URLQueryItemsBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: item)])
    }

    public func addingQueryItem<F: FloatingPoint>(_ item: F, name: String, digits: Int) -> URLQueryItemsBuilder {
        let formattedString = String(format: "%.\(digits)f", String(describing: item))

        return URLQueryItemsBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: formattedString)])
    }

    public func addingQueryItem(_ items: [String], name: String) -> URLQueryItemsBuilder {
        let itemsString = items.joined(separator: ",")

        return URLQueryItemsBuilder(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems + [URLQueryItem(name: name, value: itemsString)])
    }

    public func build() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        return components.url
    }

}
