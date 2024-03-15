import Foundation
import HTTPTypes

/// A wrapper type representing the result of a network request
public struct NetworkResponse<Output> {

    /// The actual output of the network request
    public let output: Output

    /// The original response of the network call
    public let response: HTTPResponse

    /// The time that elapsed during the actual network request
    public let networkingDuration: TimeInterval

    /// The time that elapsed during the processing of the network request's result
    public let processingDuration: TimeInterval

}
