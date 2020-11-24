import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    public let urlSession: URLSession
    public let finishingQueue: DispatchQueue
    public let requestMethod: NetworkRequestMethod
    public let authentication: NetworkRequestAuthentication?

    private let urlString: String

    open var url: URL? {
        URL(string: urlString)
    }

    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(
        urlString: String,
        urlSession: URLSession = .shared,
        finishingQueue: DispatchQueue = .main,
        requestMethod: NetworkRequestMethod = .get,
        authentication: NetworkRequestAuthentication? = nil)
    {
        self.urlString = urlString
        self.urlSession = urlSession
        self.finishingQueue = finishingQueue
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

    public init(
        url: URL,
        urlSession: URLSession = .shared,
        finishingQueue: DispatchQueue = .main,
        requestMethod: NetworkRequestMethod = .get,
        authentication: NetworkRequestAuthentication? = nil)
    {
        self.urlString = url.absoluteString
        self.urlSession = urlSession
        self.finishingQueue = finishingQueue
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

    open func convertResponse(response: NetworkResponse) throws -> Output {
        do {
            return try decoder.decode(T.self, from: response.data)
        } catch let error as NSError {
            throw error.injectJSON(response.data)
        }
    }

}
