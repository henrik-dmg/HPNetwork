import Foundation
import HTTPTypes
import HTTPTypesFoundation

// MARK: - NetworkRequest

/// A base protocol to define network requests
public protocol NetworkRequest<Output> {

    /// The expected output type returned in the network request
    associatedtype Output

    typealias RequestResult = Result<NetworkResponse<Output>, Error>

    /// The `URLSession` that will be used to schedule the network request
    ///
    /// Defaults to `URLSession.shared`
    var urlSession: URLSession { get }

    /// The header fields that will be send with the network request
    ///
    /// Defaults to an empty array
    @HTTPFieldsBuilder var headerFields: [HTTPField] { get }

    /// The request method that will be used
    var requestMethod: HTTPRequest.Method { get }

    /// The authorization method used to authorize the network request
    ///
    /// An instance of ``AuthorizationHeaderField`` will be created from this and appended to the other provided header fields. Defaults to `nil`
    var authorization: Authorization? { get }

    /// A method used to construct or create the URL of the network request
    ///
    /// This method is the very first call when calling scheduling a request
    func makeURL() throws -> URL

    /// The data that will be send in the HTTP body of the request
    ///
    /// Defaults to `nil`
    func httpBody() throws -> Data?

    /// Uses all the provided information to create a `URLRequest` and handles that request's result accordingly
    /// - Parameters:
    /// 	- delegate: The delegate that can be used to inspect and react to the network traffic while the request is running
    /// - Returns: a wrapper object containing an instance of ``Output`` along with the elapsed time for both networking and processing in seconds
    func response(delegate: URLSessionDataDelegate?) async throws -> NetworkResponse<Output>

    /// Uses all the provided information to create a `URLRequest` and handles that request's result accordingly
    /// - Parameters:
    ///     - delegate: The delegate that can be used to inspect and react to the network traffic while the request is running
    /// - Returns: a result with either a wrapper object containing an instance of ``Output`` along with the elapsed time for
    /// both networking and processing in seconds or an error
    func result(delegate: URLSessionDataDelegate?) async -> RequestResult

    /// Uses all the provided information to create a `URLRequest` and schedules that request
    /// - Parameters:
    ///   - delegate: The delegate that can be used to inspect and react to the network traffic while the request is running
    ///   - finishingQueue: The `DispatchQueue` that the completion handler will be called on
    ///   - completion: The block that will be executed with the result of the network request
    /// - Returns: A task that wraps the running network request
    func schedule(
        delegate: URLSessionDataDelegate?,
        finishingQueue: DispatchQueue,
        completion: @escaping (RequestResult) -> Void
    ) -> Task<Void, Never>

    func validateResponse(_ response: HTTPResponse) throws

}

public extension NetworkRequest {

    /// Constructs a `URLRequest` from the provided values
    /// - Returns: a new `URLRequest` instance
    func makeRequest() throws -> URLRequest {
        let url = try makeURL()
        
        var request = HTTPRequest(method: requestMethod, url: url)

        for field in headerFields {
            request.headerFields.append(field)
        }

        if let authorization {
            assert(request.headerFields[.authorization] == nil, "Authorization was already configured as part of header fields")
            request.headerFields[.authorization] = authorization.headerString
        }

        guard var urlRequest = URLRequest(httpRequest: request) else {
            throw NetworkRequestConversionError.failedToConvertHTTPRequestToURLRequest
        }
        urlRequest.httpBody = try httpBody()

        return urlRequest
    }

    func validateResponse(_ response: HTTPResponse) throws {
        switch response.status.kind {
        case .clientError, .invalid, .redirection, .serverError:
            throw URLError(URLError.Code(rawValue: response.status.code))
        case .informational, .successful:
            break
        }
    }

}

extension NetworkRequest {

    func calculateElapsedTime(startTime: DispatchTime, networkingEndTime: DispatchTime, processingEndTime: DispatchTime) -> (TimeInterval, TimeInterval) {
        let networkingTime = Double(networkingEndTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
        let processingTime = Double(processingEndTime.uptimeNanoseconds - networkingEndTime.uptimeNanoseconds)

        // converting nanoseconds to seconds
        return (networkingTime / 1e9, processingTime / 1e9)
    }

}

enum NetworkRequestConversionError: Error {
    case failedToConvertHTTPRequestToURLRequest
    case failedToConvertURLResponseToHTTPResponse
}

// MARK: - Sensible Defaults

public extension NetworkRequest {

    func httpBody() throws -> Data? { nil }

    var urlSession: URLSession { .shared }

    var headerFields: [HTTPField] { [] }

    var authorization: Authorization? { nil }

}
