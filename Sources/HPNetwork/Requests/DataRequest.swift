import Foundation

/// A protocol that's used to handle regular network request where data is downloaded
public protocol DataRequest<Output>: NetworkRequest {

    /// Called by ``response(delegate:)``, ``schedule(delegate:completion:)`` or ``result(delegate:)`` once the networking has finished.
    ///
    /// For more convenient handling of `Decodable` output types, use ``DecodableRequest``
    /// - Parameters:
    /// 	- data: The raw data returned by the networking
    /// 	- response: The network response
    /// - Returns: An instance of the specified output type
    func convertResponse(data: Data, response: URLResponse) throws -> Output

    /// Called by ``response(delegate:)``, ``schedule(delegate:completion:)`` or ``result(delegate:)``
    /// if the networking has finished successfully but `response` indicates an error.
    /// Can be used to simply log errors or inspect them otherwise
    ///
    /// The default implementation of this simply forwards the passed in error
    /// - Parameters:
    /// 	- error: The error that occured based on `response`
    ///		- data: The raw data returned by the networking
    ///		- response: The network response
    /// - Returns: The passed in or modified error
    func convertError(error: URLError, data: Data, response: URLResponse) -> Error

}

// MARK: - Scheduling and Convenience

public extension DataRequest {

    func convertError(error: URLError, data _: Data, response _: URLResponse) -> Error {
        error
    }

    @discardableResult func response(delegate: URLSessionDataDelegate? = nil) async throws -> NetworkResponse<Output> {
        let urlRequest = try urlRequest()
        let startTime = DispatchTime.now()
        let result = try await urlSession.hp_data(for: urlRequest, delegate: delegate)
        let networkingEndTime = DispatchTime.now()
        let convertedResult = try dataTaskResult(data: result.0, response: result.1)
        let processingEndTime = DispatchTime.now()
        let elapsedTime = calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
        return NetworkResponse(output: convertedResult, response: result.1, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
    }

    @discardableResult func result(delegate: URLSessionDataDelegate? = nil) async -> Result<NetworkResponse<Output>, Error> {
        do {
            let result = try await response(delegate: delegate)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    @discardableResult func schedule(
        delegate: URLSessionDataDelegate? = nil, finishingQueue: DispatchQueue = .main, completion: @escaping (RequestResult) -> Void
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

public extension DataRequest where Output == Data {

    /// Called by ``schedule(delegate:)`` once the networking has finished.
    ///
    /// - Parameters:
    /// 	- data: The raw data returned by the networking
    /// 	- response: The network response
    /// - Returns: The raw data returned by the networking
    func convertResponse(data: Data, response _: URLResponse) throws -> Output {
        data
    }

}

// MARK: - Result

extension DataRequest {

    func dataTaskResult(data: Data, response: URLResponse) throws -> Output {
        if let error = response.urlError() {
            throw convertError(error: error, data: data, response: response)
        } else {
            return try convertResponse(data: data, response: response)
        }
    }

}
