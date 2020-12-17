import Foundation

public struct RequestHeaderField {

	let name: String
	let value: String

	public static var json: RequestHeaderField {
		RequestHeaderField(name: "Content-Type", value: "application/json")
	}

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}

}

extension URLRequest {

	mutating func addHeaderField(_ field: RequestHeaderField) {
		setValue(field.value, forHTTPHeaderField: field.name)
	}

}
