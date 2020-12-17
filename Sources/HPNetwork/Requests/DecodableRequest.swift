import Foundation

public protocol DecodableRequest: NetworkRequest where Output: Decodable {

	var decoder: JSONDecoder { get }

}

extension DecodableRequest {

	public var requestMethod: RequestMethod {
		.get
	}

	public func convertResponse(response: NetworkResponse) throws -> Output {
		do {
			return try decoder.decode(Output.self, from: response.data)
		} catch let error as NSError {
			throw error.injectJSON(response.data)
		}
	}

}
