import Foundation
import HPNetwork
import HTTPTypes

public enum NetworkClientMockError: Error {
    case noMockConfiguredForRequest
}

public final class NetworkClientMock: NetworkClientProtocol {

    // MARK: - Nested Types

    private protocol MockedRequest<Request> {
        associatedtype Request: NetworkRequest
        typealias RequestHandler = (Request) async throws -> Request.Output

        var handler: RequestHandler { get }
    }

    private struct ConcreteMockedRequest<Request: NetworkRequest>: MockedRequest {
        let handler: RequestHandler
    }

    // MARK: - Properties

    public var fallbackToURLSessionIfNoMatchingMock = true
    public var urlSession: URLSession = .shared
    private var mockedRequests: [String: any MockedRequest] = [:]

    // MARK: - NetworkClientProtocol

    public func response<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> NetworkResponse<Request.Output> {
        guard let mockedRequest = mockedRequest(forType: Request.self) else {
            if fallbackToURLSessionIfNoMatchingMock {
                return try await request.response(urlSession: urlSession, delegate: delegate)
            }
            throw NetworkClientMockError.noMockConfiguredForRequest
        }
        let output = try await mockedRequest.handler(request)
        return NetworkResponse(
            output: output,
            response: HTTPResponse(status: .ok, headerFields: HTTPFields()),
            networkingDuration: 0.00,
            processingDuration: 0.00
        )
    }

    public func result<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async -> Request.RequestResult {
        do {
            let response = try await response(request, delegate: delegate)
            return .success(response)
        } catch {
            return .failure(error)
        }
    }

    public func schedule<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil,
        finishingQueue: DispatchQueue = .main,
        completion: @escaping (Request.RequestResult) -> Void
    ) -> Task<Void, Never> {
        Task {
            let result = await result(request, delegate: delegate)
            finishingQueue.async {
                completion(result)
            }
        }
    }

    // MARK: - Mocking

    public func removeAllMocks() {
        mockedRequests.removeAll()
    }

    public func mockRequest<Request: NetworkRequest>(ofType type: Request.Type, handler: @escaping (Request) async throws -> Request.Output)
    {
        let typeName = String(describing: type.self)
        mockedRequests[typeName] = ConcreteMockedRequest(handler: handler)
    }

    private func mockedRequest<Request: NetworkRequest>(forType type: Request.Type) -> ConcreteMockedRequest<Request>? {
        let typeName = String(describing: type.self)
        return mockedRequests[typeName] as? ConcreteMockedRequest<Request>
    }

}
