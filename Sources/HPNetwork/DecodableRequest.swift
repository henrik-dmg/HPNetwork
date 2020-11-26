import Foundation

open class DecodableRequest<T: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = T

    public let urlSession: URLSession
    public let finishingQueue: DispatchQueue
	private let _url: URL?

	open var requestMethod: NetworkRequestMethod {
		.get
	}

	open var authentication: NetworkRequestAuthentication? {
		nil
	}

    open var url: URL? {
		_url
    }

    open var decoder: JSONDecoder {
        JSONDecoder()
    }

    public init(
        urlString: String,
        urlSession: URLSession = .shared,
        finishingQueue: DispatchQueue = .main)
    {
        self._url = URL(string: urlString)
        self.urlSession = urlSession
        self.finishingQueue = finishingQueue
    }

    public init(
        url: URL,
        urlSession: URLSession = .shared,
        finishingQueue: DispatchQueue = .main)
    {
        self._url = url
        self.urlSession = urlSession
        self.finishingQueue = finishingQueue
    }

    open func convertResponse(response: NetworkResponse) throws -> Output {
        do {
            return try decoder.decode(T.self, from: response.data)
        } catch let error as NSError {
            throw error.injectJSON(response.data)
        }
    }

}
