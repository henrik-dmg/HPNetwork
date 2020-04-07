import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    open var url: URL? {
        URL(string: _urlString)
    }

    public let requestMethod: NetworkRequestMethod
    public let authentication: NetworkRequestAuthentication?

    private let _urlString: String

    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(urlString: String, requestMethod: NetworkRequestMethod = .get, authentication: NetworkRequestAuthentication? = nil) {
        self._urlString = urlString
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

    public func convertResponse(input: Data, response: NetworkResponse) throws -> T {
        try decoder.decode(T.self, from: input)
    }

}
