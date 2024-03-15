import Foundation

public protocol NetworkClientProtocol {

    func response<Request: NetworkRequest>(_ request: Request, delegate: (any URLSessionTaskDelegate)?) async throws -> NetworkResponse<
        Request.Output
    >
    func result<Request: NetworkRequest>(_ request: Request, delegate: (any URLSessionTaskDelegate)?) async -> Request.RequestResult
    func schedule<Request: NetworkRequest>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)?,
        finishingQueue: DispatchQueue,
        completion: @escaping (Request.RequestResult) -> Void
    ) -> Task<Void, Never>

}

public final class NetworkClient: NetworkClientProtocol {

    private let urlSession: URLSession

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
    ) async -> Request.RequestResult {
        await request.result(urlSession: urlSession, delegate: delegate)
    }

    public func schedule<Request>(
        _ request: Request,
        delegate: (any URLSessionTaskDelegate)? = nil,
        finishingQueue: DispatchQueue = .main,
        completion: @escaping (Request.RequestResult) -> Void
    ) -> Task<Void, Never> where Request: NetworkRequest {
        request.schedule(urlSession: urlSession, delegate: delegate, finishingQueue: finishingQueue, completion: completion)
    }

}
