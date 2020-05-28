import Foundation

public enum NetworkRequestAuthentication {

    case basic(username: String, password: String)
    case raw(string: String)

    internal var headerString: String {
        switch self {
        case .basic(let username, let password):
            let loginString = String(format: "%@:%@", username, password)
            let loginDataString = loginString.data(using: .utf8)!.base64EncodedString()
            return "Basic \(loginDataString)"
        case .raw(let string):
            return string
        }
    }

}
