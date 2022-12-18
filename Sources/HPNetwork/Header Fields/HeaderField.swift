import Foundation

/// A type representing a network request header field
public protocol HeaderField {

    /// The name of the header field
    var name: String { get }

    /// The value of the header field
    var value: String? { get }
}
