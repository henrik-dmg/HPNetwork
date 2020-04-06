import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    public let urlString: String
    public let requestMethod: NetworkRequestMethod = .get
    public let authentication: NetworkRequestAuthentication? = nil

    public var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(urlString: String) {
        self.urlString = urlString
    }

    public func convertResponse(input: Data, response: NetworkResponse) throws -> T {
        try decoder.decode(T.self, from: input)
    }

}
