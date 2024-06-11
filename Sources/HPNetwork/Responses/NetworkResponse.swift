import Foundation
import HTTPTypes

/// A wrapper type representing the result of a network request.
public struct NetworkResponse<Output> {

    /// The actual output of the network request.
    public let output: Output

    /// The url of the resource.
    ///
    /// For HEAD requests this will be final destination.
    public let url: URL

    /// The original response of the network call.
    public let response: HTTPResponse

    /// The time that elapsed during the actual network request.
    public let networkingDuration: TimeInterval

    /// The time that elapsed during the processing of the network request's result.
    public let processingDuration: TimeInterval

    /// Creates a new `NetworkResponse`.
    /// - Parameters:
    ///   - output: The actual output of the network request.
    ///   - url: The URL that handled the request
    ///   - response: The original response of the network call.
    ///   - networkingDuration: The time that elapsed during the actual network request.
    ///   - processingDuration: The time that elapsed during the processing of the network request's result.
    public init(output: Output, url: URL, response: HTTPResponse, networkingDuration: TimeInterval, processingDuration: TimeInterval) {
        self.output = output
        self.url = url
        self.response = response
        self.networkingDuration = networkingDuration
        self.processingDuration = processingDuration
    }

}
