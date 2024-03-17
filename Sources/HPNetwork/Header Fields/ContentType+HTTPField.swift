import Foundation
import HTTPTypes

/// Common content types for network requests.
public enum ContentType: String {
    /// `application/json`
    case applicationJSON = "application/json"
}

extension HTTPField {

    /// Convenience method to create a `Content-Type` header field with the specified content type.
    /// - Parameter type: The content type for the header field
    /// - Returns: A `Content-Type` header field with the specified content type
    public static func contentType(_ type: ContentType) -> HTTPField {
        HTTPField(name: .contentType, value: type.rawValue)
    }

    /// Convenience method to create a `Accept` header field with the specified content type.
    /// - Parameter type: The content type for the header field
    /// - Returns: A `Accept` header field with the specified content type
    public static func accept(_ type: ContentType) -> HTTPField {
        HTTPField(name: .accept, value: type.rawValue)
    }

}
