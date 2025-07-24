import Foundation
import HTTPTypes

public protocol DownloadRequest: NetworkRequest where Output == URL {

    func convertResponse(url: URL, response: HTTPResponse) throws -> Output

}

// MARK: - Scheduling and Convenience

extension DownloadRequest {

    public func convertResponse(url: URL, response: HTTPResponse) throws -> Output {
        url
    }

    @discardableResult
    public func response(urlSession: URLSession, delegate: (any URLSessionTaskDelegate)?) async throws -> Response {
        let request = try makeRequest()
        let startTime = DispatchTime.now()

        // Check for cancellation
        try Task.checkCancellation()

        let (url, response) = try await urlSession.download(for: request, delegate: delegate)
        let networkingEndTime = DispatchTime.now()

        // Check for cancellation
        try Task.checkCancellation()

        guard
            let httpURLResponse = response as? HTTPURLResponse,
            let httpResponse = httpURLResponse.httpResponse,
            let httpURL = httpURLResponse.url
        else {
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
            url: httpURL,
            response: httpResponse,
            networkingDuration: elapsedTime.0,
            processingDuration: elapsedTime.1
        )
    }

    @discardableResult
    public func result(urlSession: URLSession, delegate: (any URLSessionTaskDelegate)?) async -> NetworkResult {
        do {
            let result = try await response(urlSession: urlSession, delegate: delegate)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    @discardableResult
    public func schedule(urlSession: URLSession, delegate: (any URLSessionTaskDelegate)?) -> NetworkTask where Output: Sendable {
        NetworkTask {
            try await response(urlSession: urlSession, delegate: delegate)
        }
    }

}
