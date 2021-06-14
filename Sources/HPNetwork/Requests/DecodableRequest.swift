import Foundation

public protocol DecodableRequest: DataRequest where Output: Decodable {

	var decoder: JSONDecoder { get }

	var injectJSONOnError: Bool { get }

}

extension DecodableRequest {

	public var injectJSONOnError: Bool { false }

	public func convertResponse(data: Data, response: URLResponse) throws -> Output {
		do {
			return try decoder.decode(Output.self, from: data)
		} catch let error as NSError {
			if injectJSONOnError {
				throw error.injectJSON(data)
			} else {
				throw error
			}
		}
	}

}
