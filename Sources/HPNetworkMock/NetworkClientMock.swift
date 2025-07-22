import Foundation
import HTTPTypes

@testable import HPNetwork

public enum NetworkClientMockError: Error {
    case noMockConfiguredForRequest
}

protocol MockedRequest<Request> {
    associatedtype Request: NetworkRequest
    typealias RequestHandler = (Request) async throws -> Request.Output
}

/// A mockable network client.
public final class NetworkClientMock: NetworkClientProtocol, Sendable {

    // MARK: - Nested Types

    // periphery:ignore
    struct ConcreteMockedRequest<Request: NetworkRequest>: MockedRequest {
        let handler: RequestHandler
    }

    // MARK: - Properties

    public let urlSession: URLSession
    public let fallbackToURLSessionIfNoMatchingMock: Bool

    /// All mutable state is stored in this actor for concurrency safety.
    private let store = MockedRequestsStore()

    // MARK: - Init

    public init(urlSession: URLSession = .shared, fallbackToURLSessionIfNoMatchingMock: Bool = false) {
        self.urlSession = urlSession
        self.fallbackToURLSessionIfNoMatchingMock = fallbackToURLSessionIfNoMatchingMock
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
        } else if fallbackToURLSessionIfNoMatchingMock {
            return try await request.response(urlSession: urlSession, delegate: delegate)
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
