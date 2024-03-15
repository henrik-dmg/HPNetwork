import Foundation
import HTTPTypes

/// A protocol that's used to handle network request where the downloaded data is converted into a `Decodable` type
public protocol DecodableRequest<Output>: DataRequest where Output: Decodable {

    /// The decoder used to decode the downloaded data
    var decoder: JSONDecoder { get }

}

extension DecodableRequest {

    public var injectJSONOnError: Bool { false }

    public func convertResponse(data: Data, response _: HTTPResponse) throws -> Output {
        try decoder.decode(Output.self, from: data)
    }

}
