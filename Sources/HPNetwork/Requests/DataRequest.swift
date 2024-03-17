import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A protocol that's used to handle regular network request where data is downloaded.
public protocol DataRequest<Output>: NetworkRequest {

    /// Called by ``response(delegate:)``, ``schedule(delegate:completion:)`` or ``result(delegate:)`` once the networking has finished.
    ///
    /// For more convenient handling of `Decodable` output types, use ``DecodableRequest``
    /// - Parameters:
    ///  - data: The raw data returned by the networking
    ///  - response: The network response
    /// - Returns: An instance of the specified output type
    /// - Throws: When converting the data to the desired output type failed
    func convertResponse(data: Data, response: HTTPResponse) throws -> Output

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
        // Actually execute network request
        let (data, response) = try await urlSession.data(for: request, delegate: delegate)
        // Keep track of networking duration
        let networkingEndTime = DispatchTime.now()
        // Convert response
        guard let httpResponse = (response as? HTTPURLResponse)?.httpResponse else {
            throw NetworkRequestConversionError.failedToConvertURLResponseToHTTPResponse
        }
        // Validate response and convert output
        try validateResponse(httpResponse)
        let convertedResult = try convertResponse(data: data, response: httpResponse)
        // Calculate total elapsed times
        let elapsedTime = calculateElapsedTime(
            startTime: startTime,
            networkingEndTime: networkingEndTime,
            processingEndTime: DispatchTime.now()
        )
        // Return a NetworkResponse
        return NetworkResponse(
            output: convertedResult,
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
    /// - Returns: The raw data returned by the networking
    /// - Throws: Doesn't throw, because the input `data` is simply forwarded
    public func convertResponse(data: Data, response: HTTPResponse) throws -> Output {
        data
    }

}
