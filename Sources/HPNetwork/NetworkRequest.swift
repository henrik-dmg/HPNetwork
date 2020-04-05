import Foundation

/**
 A protocol to wrap request objects. This gives us a better API over URLRequest.
 */
public protocol NetworkRequestable {

    associatedtype ResultType: Decodable
    /**
     Generates a URLRequest from the request. This will be run on a background thread so model parsing is allowed.
     */
    func urlRequest() -> URLRequest
}

public enum NetworkRequestMethod: String {
    case get = "GET"
    case post = "POST"
}

/**
A simple request with no post data.
*/
public class NetworkRequest<R: Decodable>: NetworkRequestable {

    public typealias ResultType = R

    let urlString: String
    let method: NetworkRequestMethod

    init(url: String, method: NetworkRequestMethod = .get) {
        self.urlString = url
        self.method = method
    }

    public func urlRequest() -> URLRequest {
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }

}

/**
 A request which includes post data. This should be the form of an encodeable model.
 */
public struct NetworkPostRequest<T: Encodable, R: Decodable>: NetworkRequestable {

    public typealias ResultType = R

    let urlString: String
    let encoder: JSONEncoder
    let method: NetworkRequestMethod
    let model: T

    public init(url: String, encoder: JSONEncoder = .init(), method: NetworkRequestMethod = .get, model: T) {
        self.urlString = url
        self.encoder = encoder
        self.method = method
        self.model = model
    }

    public func urlRequest() -> URLRequest {
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        do {
            let data = try encoder.encode(model)
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
            print("Post request model parsing failed: \(error.localizedDescription)")
        }

        return urlRequest
    }
}

///**
// Making URLRequest also conform to request so it can be used with our stack.
// */
//extension URLRequest: NetworkRequestable {
//
//    public func urlRequest() -> URLRequest {
//        return self
//    }
//
//}
