import Foundation

public struct NetworkRequestHeaderField {

	let name: String
	let value: String

	public static let contentTypeJSON = NetworkRequestHeaderField(name: "Content-Type", value: "application/json")
	public static let acceptJSON = NetworkRequestHeaderField(name: "Accept", value: "application/json")
	public static let acceptCharsetUTF8 = NetworkRequestHeaderField(name: "Accept-Charset", value: "utf-8")

	@available(*, deprecated, renamed: "contentTypeJSON")
	public static var json: NetworkRequestHeaderField {
		contentTypeJSON
	}

	public static func musicUserToken(_ userToken: String) -> NetworkRequestHeaderField {
		NetworkRequestHeaderField(name: "Music-User-Token", value: userToken)
	}

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}

}

extension URLRequest {

	mutating func addHeaderField(_ field: NetworkRequestHeaderField) {
		setValue(field.value, forHTTPHeaderField: field.name)
	}

}
