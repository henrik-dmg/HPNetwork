import Foundation

/// A protocol that's used to handle network request where the downloaded data is converted into a `Decodable` type
public protocol DecodableRequest<Output>: DataRequest where Output: Decodable {

    /// The decoder used to decode the downloaded data
    var decoder: JSONDecoder { get }

    /// A boolean indicating whether the downloaded data should be added the error in case the decoding of the desired type fails
    ///
    /// Defaults to false
    var injectJSONOnError: Bool { get }

}

public extension DecodableRequest {

    var injectJSONOnError: Bool { false }

    func convertResponse(data: Data, response _: URLResponse) throws -> Output {
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
