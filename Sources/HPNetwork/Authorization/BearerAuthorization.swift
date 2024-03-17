import Foundation

/// A type representing Bearer authorization using a token for network requests.
public struct BearerAuthorization: Authorization {

    public let headerString: String

    /// Creates a new bearer authorization instance.
    /// - Parameter bearerToken: The token to use with the authorization
    public init(_ bearerToken: String) {
        headerString = "Bearer \(bearerToken)"
    }

}
