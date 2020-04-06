import Foundation

/**
 A request which includes post data. This should be the form of an encodeable model.
 */
public struct DecodableRequest<ResultType: Decodable>: NetworkRequest {

    public typealias Input = Data
    public typealias Output = ResultType

    public let urlString: String
    let method: NetworkRequestMethod

    public init(urlString: String, method: NetworkRequestMethod = .get) {
        self.urlString = urlString
        self.method = method
    }

    public init?(urlRequest: URLRequest, method: NetworkRequestMethod = .get) {
        guard let url = urlRequest.url else {
            return nil
        }
        self.init(urlString: url.absoluteString, method: method)
    }

    public func urlRequest() -> URLRequest? {
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

//        if let model = model {
//            do {
//                let data = try encoder.encode(model)
//                urlRequest.httpBody = data
//                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            } catch let error {
//                print("Post request model parsing failed: \(error.localizedDescription)")
//            }
//        }

        return urlRequest
    }

}
