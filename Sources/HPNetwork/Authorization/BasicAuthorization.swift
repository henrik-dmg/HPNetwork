import Foundation

/// A type representing basic authorization for network requests.
public struct BasicAuthorization: Authorization {

    public let headerString: String

    /// Creates a new basic authorization instance.
    /// - Parameters:
    ///   - username: The username to encode
    ///   - password: The password to encode
    public init?(username: String, password: String) {
        let loginString = String(format: "%@:%@", username, password)
        guard let loginDataString = loginString.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }
        headerString = "Basic \(loginDataString)"
    }

}
