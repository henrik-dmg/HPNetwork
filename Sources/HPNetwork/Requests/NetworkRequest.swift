import Foundation

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
    @HeaderFieldBuilder var headerFields: [HeaderField] { get }

    /// The request method that will be used
    var requestMethod: RequestMethod { get }

    /// The authorization method used to authorize the network request
    ///
    /// An instance of ``AuthorizationHeaderField`` will be created from this and appended to the other provided header fields. Defaults to `nil`
    var authorization: Authorization? { get }

    /// A method used to construct or create the URL of the network request
    ///
    /// This method is the very first call when calling ``response(delegate:)``, ``result(delegate:)`` or ``schedule(delegate:finishingQueue:completion:)``
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

}

public extension NetworkRequest {

    /// Constructs a `URLRequest` from the provided values
    /// - Returns: a new `URLRequest` instance
    func urlRequest() throws -> URLRequest {
        let url = try makeURL()

        var request = URLRequest(url: url)
        request.httpMethod = requestMethod.rawValue
        request.httpBody = try httpBody()
        headerFields.forEach {
            request.addHeaderField($0)
        }

        if let auth = authorization {
            request.addHeaderField(AuthorizationHeaderField(auth))
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

    func httpBody() throws -> Data? { nil }

    var urlSession: URLSession { .shared }

    var headerFields: [HeaderField] { [] }

    var authorization: Authorization? { nil }

}
