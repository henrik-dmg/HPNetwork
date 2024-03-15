import Foundation
import HTTPTypes
import HTTPTypesFoundation

/// A protocol that's used to handle regular network request where data is downloaded
public protocol DataRequest<Output>: NetworkRequest {

    /// Called by ``response(delegate:)``, ``schedule(delegate:completion:)`` or ``result(delegate:)`` once the networking has finished.
    ///
    /// For more convenient handling of `Decodable` output types, use ``DecodableRequest``
    /// - Parameters:
    /// 	- data: The raw data returned by the networking
    /// 	- response: The network response
    /// - Returns: An instance of the specified output type
    func convertResponse(data: Data, response: HTTPResponse) throws -> Output

}

// MARK: - Scheduling and Convenience

extension DataRequest {

    @discardableResult public func response(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
        let request = try makeRequest()

        let startTime = DispatchTime.now()

        let (data, response) = try await urlSession.data(for: request, delegate: delegate)

        let networkingEndTime = DispatchTime.now()

        guard let httpResponse = (response as? HTTPURLResponse)?.httpResponse else {
            throw NetworkRequestConversionError.failedToConvertURLResponseToHTTPResponse
        }

        try validateResponse(httpResponse)
        let convertedResult = try convertResponse(data: data, response: httpResponse)

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

    @discardableResult public func schedule(
        delegate: URLSessionDataDelegate? = nil,
        finishingQueue: DispatchQueue = .main,
        completion: @escaping (RequestResult) -> Void
    ) -> Task<Void, Never> {
        Task {
            let result = await result(delegate: delegate)
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
    /// 	- data: The raw data returned by the networking
    /// 	- response: The network response
    /// - Returns: The raw data returned by the networking
    public func convertResponse(data: Data, response _: HTTPResponse) throws -> Output {
        data
    }

}
