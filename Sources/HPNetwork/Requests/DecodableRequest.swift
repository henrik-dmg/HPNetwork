import Foundation

public protocol DecodableRequest: DataRequest where Output: Decodable {

	var decoder: JSONDecoder { get }

	var injectJSONOnError: Bool { get }

}

extension DecodableRequest {

	public var injectJSONOnError: Bool { true }

	public func convertResponse(response: DataResponse) throws -> Output {
		do {
			return try decoder.decode(Output.self, from: response.data)
		} catch let error as NSError {
			if injectJSONOnError {
				throw error.injectJSON(response.data)
			} else {
				throw error
			}
		}
	}

}
