import Foundation

/// A wrapper type representing the result of a network request
public struct NetworkResponse<T> {

    /// The actual output of the network request
    public let output: T

    /// The original response of the network call
    public let response: URLResponse

    /// The time that elapsed during the actual network request
    public let networkingDuration: TimeInterval

    /// The time that elapsed during the processing of the network request's result
    public let processingDuration: TimeInterval

}
