import Foundation

/**
 A protocol to wrap request objects. This gives us a better API over URLRequest.
 */
public protocol NetworkRequest {

    associatedtype Input
    associatedtype Output
    /**
     Generates a URLRequest from the request. This will be run on a background thread so model parsing is allowed.
     */
    func urlRequest() -> URLRequest?

    var urlString: String { get }

    func convertInput(response: NetworkResponse) throws -> Input
    func convertResponse(input: Input, response: NetworkResponse) throws -> Output

}

public extension NetworkRequest {

    func urlRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        return URLRequest(url: url)
    }

}

extension NetworkRequest where Input == Data {

    public func convertInput(response: NetworkResponse) throws -> Data {
        response.data
    }

}

extension NetworkRequest where Output == Data {

    public func convertResponse(input: Data, response: NetworkResponse) throws -> Output {
        input
    }

}

extension NetworkRequest where Output: Decodable {

    public func convertResponse(input: Data, response: NetworkResponse) throws -> Output {
        try JSONDecoder().decode(Output.self, from: input)
    }

}

public enum NetworkRequestMethod: String {

    case get = "GET"
    case post = "POST"
    case head = "HEAD"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"

}
