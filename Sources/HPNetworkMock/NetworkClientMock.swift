import Foundation
import HTTPTypes

@testable import HPNetwork

public enum NetworkClientMockError: Error {
    case noMockConfiguredForRequest
}

private protocol MockedRequest<Request> {
    associatedtype Request: NetworkRequest
    typealias RequestHandler = (Request) async throws -> Request.Output
}

// MARK: - Actor for Concurrency Safety

/// Stores all mutable state for NetworkClientMock, ensuring thread safety.
private actor MockedRequestsStore {

    var fallbackToURLSessionIfNoMatchingMock: Bool = true
    var urlSession: URLSession = .shared
    private var mockedRequests: [String: any MockedRequest] = [:]

    func getFallbackToURLSession() -> Bool {
        fallbackToURLSessionIfNoMatchingMock
    }

    func setFallbackToURLSession(_ value: Bool) {
        fallbackToURLSessionIfNoMatchingMock = value
    }

    func getURLSession() -> URLSession {
        urlSession
    }

    func setURLSession(_ session: URLSession) {
        urlSession = session
    }

    func removeAllMocks() {
        mockedRequests.removeAll()
    }

    func mockRequest<Request: NetworkRequest>(
        ofType type: Request.Type,
        handler: @escaping (Request) async throws -> Request.Output
    ) {
        let typeName = String(describing: type.self)
        mockedRequests[typeName] = NetworkClientMock.ConcreteMockedRequest(handler: handler)
    }

    /// Handles the mock request internally and returns the output or nil if not found.
    func handleMockedRequest<Request: NetworkRequest>(
        for request: Request
    ) async throws -> Request.Output? where Request.Output: Sendable {
        let typeName = String(describing: Request.self)
        guard
            let concrete = mockedRequests[typeName]
                as? NetworkClientMock.ConcreteMockedRequest<Request>
        else {
            return nil
        }
        return try await concrete.handler(request)
    }

}

/// A mockable network client.
public final class NetworkClientMock: NetworkClientProtocol, Sendable {

    // MARK: - Nested Types

    // periphery:ignore
    fileprivate struct ConcreteMockedRequest<Request: NetworkRequest>: MockedRequest {
        let handler: RequestHandler
    }

    // MARK: - Properties

    /// All mutable state is stored in this actor for concurrency safety.
    private let store = MockedRequestsStore()

    // MARK: - Thread-safe accessors for mutable state
    /// Gets the ``fallbackToURLSessionIfNoMatchingMock`` flag.
    public func getFallbackToURLSessionIfNoMatchingMock() async -> Bool {
        await store.getFallbackToURLSession()
    }
    /// Sets the ``fallbackToURLSessionIfNoMatchingMock`` flag.
    public func setFallbackToURLSessionIfNoMatchingMock(_ value: Bool) async {
        await store.setFallbackToURLSession(value)
    }
    /// Gets the `URLSession`.
    public func getURLSession() async -> URLSession {
        await store.getURLSession()
    }
    /// Sets the `URLSession`.
    public func setURLSession(_ session: URLSession) async {
        await store.setURLSession(session)
    }

    // MARK: - NetworkClientProtocol

    public func response<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> NetworkResponse<Request.Output> where Request.Output: Sendable {
        if let output = try await store.handleMockedRequest(for: request) {
            // swift-format-ignore
            return NetworkResponse(
                output: output,
                url: URL(string: "https://apple.com")!,
                response: HTTPResponse(status: .ok, headerFields: HTTPFields()),
                networkingDuration: 0.00,
                processingDuration: 0.00
            )
        } else if await store.getFallbackToURLSession() {
            let session = await store.getURLSession()
            return try await request.response(urlSession: session, delegate: delegate)
        } else {
            throw NetworkClientMockError.noMockConfiguredForRequest
        }
    }

    public func result<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async -> Request.NetworkResult where Request.Output: Sendable {
        do {
            let response = try await response(request, delegate: delegate)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func schedule<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) -> Request.NetworkTask where Request.Output: Sendable {
        // The closure is safe because all mutable state is in the actor
        Request.NetworkTask {
            try await self.response(request, delegate: delegate)
        }
    }

    // MARK: - Mocking

    /// Removes all registered mocks.
    public func removeAllMocks() async {
        await store.removeAllMocks()
    }

    /// Registers a mock handler for a specific request type.
    public func mockRequest<Request: NetworkRequest>(
        ofType type: Request.Type,
        handler: @escaping @Sendable (Request) async throws -> Request.Output
    ) async where Request.Output: Sendable {
        await store.mockRequest(ofType: type, handler: handler)
    }

}
