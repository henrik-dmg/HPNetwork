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
public final class NetworkClientMock: NetworkClientProtocol {

    // MARK: - Nested Types

    // periphery:ignore
    struct ConcreteMockedRequest<Request: NetworkRequest>: MockedRequest {
        let handler: RequestHandler
    }

    // MARK: - Properties

    public let urlSession: URLSession
    public let fallbackToURLSessionIfNoMatchingMock: Bool

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
        if let mockedRequest = await NetworkRequestMockStore.shared.mockedRequest(for: request) {
            // swift-format-ignore
            return NetworkResponse(
                output: try mockedRequest.transform(request),
                url: try request.makeURL(),
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

}
