import Foundation

// MARK: - NetworkRequest

/// A base protocol to define network requests
public protocol NetworkRequest {

    /// The expected output type returned in the network request
    associatedtype Output

    /// The data that will be send in the HTTP body of the request
    ///
    /// Defaults to `nil`
    var httpBody: Data? { get }

    /// The `URLSession` that will be used to schedule the network request
    ///
    /// Defaults to `URLSession.shared`
    var urlSession: URLSession { get }

    /// The header fields that will be send with the network request
    ///
    /// Defaults to an empty array
    var headerFields: [NetworkRequestHeaderField] { get }

    /// The request method that will be used
    var requestMethod: NetworkRequestMethod { get }

    /// The authentication method used to authenticate the network request
    ///
    /// An appropriate instance of ``NetworkRequestHeaderField`` will be created from this and appended to the other provided header fields. Defaults to `nil`
    var authentication: NetworkRequestAuthentication? { get }

    /// A method used to construct or create the URL of the network request
    ///
    /// This method is the very first call when calling ``schedule(delegate:)``
    func makeURL() throws -> URL

    /// Uses all the provided information to create a `URLRequest` and handles that request's result accordingly
    /// - Parameters:
    /// 	- delegate: The delegate that can be used to inspect and react to the network traffic while the request is running
    /// - Returns: a wrapper object containing an instance of ``Output`` along with the elapsed time for both networking and processing in seconds
    func response(delegate: URLSessionDataDelegate?) async throws -> NetworkResponse<Output>

}

public extension NetworkRequest {

    /// Constructs a `URLRequest` from the provided values
    /// - Returns: a new `URLRequest` instance
    func urlRequest() throws -> URLRequest {
        let url = try makeURL()

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.httpBody = httpBody
        headerFields.forEach {
            request.addHeaderField($0)
        }

        if let auth = authentication {
            guard let field = auth.headerField else {
                throw NSError.failedToCreateRequest.withFailureReason("Could not create authorisation header field: \(auth)")
            }
            request.addHeaderField(field)
        }

        return request
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

// MARK: - Sensible Defaults

public extension NetworkRequest {

    var httpBody: Data? { nil }

    var urlSession: URLSession { .shared }

    var headerFields: [NetworkRequestHeaderField] { [] }

    var authentication: NetworkRequestAuthentication? { nil }

}
