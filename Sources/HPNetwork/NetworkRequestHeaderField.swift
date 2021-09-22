import Foundation

/// A type representing a network request header field
public struct NetworkRequestHeaderField: Codable, Hashable, Equatable {

	/// The name of the header field
	public let name: String

	/// The value of the header field
	public let value: String

	/// A header field specifying a `application/json` content type
	public static let contentTypeJSON = NetworkRequestHeaderField(name: "Content-Type", value: "application/json")
	/// A header field specifying `application/json` as accepted content type
	public static let acceptJSON = NetworkRequestHeaderField(name: "Accept", value: "application/json")
	/// A header field specifying `utf-8` as accepted character set
	public static let acceptCharsetUTF8 = NetworkRequestHeaderField(name: "Accept-Charset", value: "utf-8")

	/// Created a new instance of a network request header field
	///
	/// - Parameters:
	///   - name: The name of the header field
	///   - value: The value of the header field
	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}

}

public extension URLRequest {

	/// Adds a new header field with specified name and value
	/// - Parameter field: The header field that will be added to the request
	mutating func addHeaderField(_ field: NetworkRequestHeaderField) {
		setValue(field.value, forHTTPHeaderField: field.name)
	}

}
