import Foundation

public enum NetworkRequestAuthentication {

    case basic(username: String, password: String)
    case raw(string: String)
    case bearer(token: String)

    var headerString: String? {
        switch self {
        case let .basic(username, password):
            let loginString = String(format: "%@:%@", username, password)
            guard let loginDataString = loginString.data(using: .utf8)?.base64EncodedString() else {
                return nil
            }
            return "Basic \(loginDataString)"
        case let .raw(string):
            return string
        case let .bearer(token):
            return "Bearer \(token)"
        }
    }

    var headerField: NetworkRequestHeaderField? {
        guard let headerString = headerString else {
            return nil
        }
        return NetworkRequestHeaderField(name: "Authorization", value: headerString)
    }

}
