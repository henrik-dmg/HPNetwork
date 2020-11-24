import Foundation

public struct NetworkRequestHeaderField {

	let name: String
	let value: String

	public static var json: NetworkRequestHeaderField {
		NetworkRequestHeaderField(name: "Content-Type", value: "application/json")
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
