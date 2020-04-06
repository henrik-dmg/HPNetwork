import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    open var urlString: String {
        _urlString
    }

    public let requestMethod: NetworkRequestMethod = .get
    public let authentication: NetworkRequestAuthentication? = nil

    private let _urlString: String

    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(urlString: String) {
        self._urlString = urlString
    }

    public func convertResponse(input: Data, response: NetworkResponse) throws -> T {
        try decoder.decode(T.self, from: input)
    }

}
