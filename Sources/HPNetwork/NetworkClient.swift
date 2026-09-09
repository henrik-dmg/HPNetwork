import Foundation

/// A type that can schedule and handle network requests.
public protocol NetworkClientProtocol: Sendable {

    func response<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> NetworkResponse<Request.Output>

    func result<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?
    ) async -> Request.NetworkResult

    func schedule<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?
    ) -> Request.NetworkTask

}

/// A type that can schedule and handle network requests.
public final class NetworkClient: NetworkClientProtocol, Sendable {

    /// The `URLSession` instance that will be used to execute network requests.
    private let urlSession: URLSession

    /// Creates a new network client.
    /// - Parameter urlSession: The `URLSession` instance that will be used to execute network requests
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func response<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> NetworkResponse<Request.Output> {
        try await request.response(urlSession: urlSession, delegate: delegate)
    }

    public func result<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async -> Request.NetworkResult {
        await request.result(urlSession: urlSession, delegate: delegate)
    }

    public func schedule<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) -> Request.NetworkTask where Request.Output: Sendable {
        request.schedule(urlSession: urlSession, delegate: delegate)
    }

}
