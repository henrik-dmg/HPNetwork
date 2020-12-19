import Foundation

public protocol DecodableRequest: DataRequest where Output: Decodable {

	var decoder: JSONDecoder { get }

}

extension DecodableRequest {

	public func convertResponse(response: NetworkResponse) throws -> Output {
		do {
			return try decoder.decode(Output.self, from: response.data)
		} catch let error as NSError {
			throw error.injectJSON(response.data)
		}
	}

}
