import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    public var url: URL?
    public let finishingQueue: DispatchQueue
    public let requestMethod: NetworkRequestMethod
    public let authentication: NetworkRequestAuthentication?

    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(
        urlString: String,
        finishingQueue: DispatchQueue = .main,
        requestMethod: NetworkRequestMethod = .get,
        authentication: NetworkRequestAuthentication? = nil)
    {
        self.url = URL(string: urlString)
        self.finishingQueue = finishingQueue
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

    public init(
        url: URL,
        finishingQueue: DispatchQueue = .main,
        requestMethod: NetworkRequestMethod = .get,
        authentication: NetworkRequestAuthentication? = nil)
    {
        self.url = url
        self.finishingQueue = finishingQueue
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

    public func convertResponse(response: NetworkResponse) throws -> Output {
        do {
            return try decoder.decode(T.self, from: response.data)
        } catch let error as NSError {
            throw error.injectJSON(response.data)
        }
    }

}
