import Foundation

public struct BasicAuthorization: Authorization {

    public let headerString: String

    public init?(username: String, password: String) {
        let loginString = String(format: "%@:%@", username, password)
        guard let loginDataString = loginString.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }
        headerString = "Basic \(loginDataString)"
    }

}
