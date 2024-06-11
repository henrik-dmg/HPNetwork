import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A protocol that's used to handle regular network request where data is downloaded.
public protocol DataRequest<Output>: NetworkRequest {

    /// Use this method to conver the `Data` returned by the networking to your desired `Output` type.
    /// For more convenient handling of `Decodable` output types, use ``DecodableRequest``
    ///
    /// Called by ``response(urlSession:delegate:)``,  ``result(urlSession:delegate:)``
    /// or ``schedule(urlSession:delegate:finishingQueue:completion:)`` once the networking has finished.
    /// - Parameters:
    ///   - data: The raw data returned by the networking
    ///   - response: The network response
    ///   - url: The URL that handled the request
    /// - Returns: An instance of the specified output type
    /// - Throws: When converting the data to the desired output type failed
    func convertResponse(data: Data, response: HTTPResponse, url: URL) throws -> Output

    /// Executes the request and returns the response.
    /// - Parameters:
    ///   - urlSession: The `URLSession` instance to use to execute the request
    ///   - delegate: The delegate to use
    /// - Returns: The network response containing the converted output along with some metadata
    /// - Throws: If the networking failed or converting the response to the desired output type failed
    func response(urlSession: URLSession, delegate: (any URLSessionTaskDelegate)?) async throws -> NetworkResponse<Output>

    /// Executes the request and returns the result.
    /// - Parameters:
    ///   - urlSession: The `URLSession` instance to use to execute the request
    ///   - delegate: The delegate to use
    /// - Returns: The result of the network request
    func result(urlSession: URLSession, delegate: (any URLSessionTaskDelegate)?) async -> RequestResult

    /// Executes the request and calls the completion handler with the result.
    /// - Parameters:
    ///   - urlSession: The `URLSession` instance to use to execute the request
    ///   - delegate: The delegate to use
    ///   - finishingQueue: The `DispatchQueue` that the `completion` will be called on
    ///   - completion: The completion handler
    /// - Returns: A cancellable `Task` instance
    func schedule(
        urlSession: URLSession,
        delegate: (any URLSessionTaskDelegate)?,
        finishingQueue: DispatchQueue,
        completion: @escaping (RequestResult) -> Void
    ) -> Task<Void, Never>

}

// MARK: - Scheduling and Convenience

extension DataRequest {

    @discardableResult public func response(
        urlSession: URLSession,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> NetworkResponse<Output> {
        // Make request
        let request = try makeRequest()
        // Keep track of start time
        let startTime = DispatchTime.now()
        // Check for cancellation
        try Task.checkCancellation()
        // Actually execute network request
        let (data, response) = try await urlSession.data(for: request, delegate: delegate)
        // Check for cancellation
        try Task.checkCancellation()
        // Keep track of networking duration
        let networkingEndTime = DispatchTime.now()
        // Convert response
        guard
            let httpURLResponse = response as? HTTPURLResponse,
            let httpResponse = httpURLResponse.httpResponse,
            let url = httpURLResponse.url
        else {
            throw NetworkRequestConversionError.failedToConvertURLResponseToHTTPResponse
        }
        // Validate response and convert output
        try validateResponse(httpResponse)
        let convertedResult = try convertResponse(data: data, response: httpResponse, url: url)
        // Calculate total elapsed times
        let elapsedTime = calculateElapsedTime(
            startTime: startTime,
            networkingEndTime: networkingEndTime,
            processingEndTime: DispatchTime.now()
        )
        // Return a NetworkResponse
        return NetworkResponse(
            output: convertedResult,
            url: url,
            response: httpResponse,
            networkingDuration: elapsedTime.0,
            processingDuration: elapsedTime.1
        )
    }

    @discardableResult public func result(
        urlSession: URLSession,
        delegate: (any URLSessionTaskDelegate)?
    ) async -> RequestResult {
        do {
            let result = try await response(urlSession: urlSession, delegate: delegate)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    @discardableResult public func schedule(
        urlSession: URLSession,
        delegate: (any URLSessionTaskDelegate)?,
        finishingQueue: DispatchQueue = .main,
        completion: @escaping (RequestResult) -> Void
    ) -> Task<Void, Never> {
        Task {
            let result = await result(urlSession: urlSession, delegate: delegate)
            finishingQueue.async {
                completion(result)
            }
        }
    }

}

// MARK: - Raw Data

extension DataRequest where Output == Data {

    /// Called by ``schedule(delegate:)`` once the networking has finished.
    ///
    /// - Parameters:
    ///  - data: The raw data returned by the networking
    ///  - response: The network response
    ///  - url: The URL that handled the request
    /// - Returns: The raw data returned by the networking
    /// - Throws: Doesn't throw, because the input `data` is simply forwarded
    public func convertResponse(data: Data, response: HTTPResponse, url: URL) throws -> Output {
        data
    }

}
