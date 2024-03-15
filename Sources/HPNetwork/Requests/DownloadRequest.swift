import Foundation
import HTTPTypes

public protocol DownloadRequest: NetworkRequest where Output == URL {

    func convertResponse(url: URL, response: HTTPResponse) throws -> Output

}

// MARK: - Scheduling and Convenience

extension DownloadRequest {

    public func convertResponse(url: URL, response _: URLResponse) throws -> Output {
        url
    }

    @discardableResult public func response(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
        let request = try makeRequest()
        let startTime = DispatchTime.now()

        let (url, response) = try await urlSession.download(for: request, delegate: delegate)

        let networkingEndTime = DispatchTime.now()

        guard let httpResponse = (response as? HTTPURLResponse)?.httpResponse else {
            throw NetworkRequestConversionError.failedToConvertURLResponseToHTTPResponse
        }

        try validateResponse(httpResponse)
        let convertedResult = try convertResponse(url: url, response: httpResponse)

        let processingEndTime = DispatchTime.now()

        let elapsedTime = calculateElapsedTime(
            startTime: startTime,
            networkingEndTime: networkingEndTime,
            processingEndTime: processingEndTime
        )
        return NetworkResponse(
            output: convertedResult,
            response: httpResponse,
            networkingDuration: elapsedTime.0,
            processingDuration: elapsedTime.1
        )
    }

    @discardableResult public func result(delegate: URLSessionDataDelegate? = nil) async -> Result<NetworkResponse<Output>, Error> {
        do {
            let result = try await response(delegate: delegate)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    public func schedule(
        delegate: URLSessionDataDelegate? = nil,
        finishingQueue: DispatchQueue = .main,
        completion: @escaping (RequestResult) -> Void
    ) -> Task<
        Void, Never
    > {
        Task {
            let result = await result(delegate: delegate)
            finishingQueue.async {
                completion(result)
            }
        }
    }

}
