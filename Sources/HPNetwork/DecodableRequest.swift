import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    public let urlString: String
    public let requestMethod: NetworkRequestMethod = .get
    public let authentication: NetworkRequestAuthentication? = nil

    public init(urlString: String) {
        self.urlString = urlString
    }

}
