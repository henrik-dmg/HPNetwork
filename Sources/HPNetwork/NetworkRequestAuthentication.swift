import Foundation

public enum NetworkRequestAuthentication {

    case basic(username: String, password: String)
    case raw(string: String)
    case bearer(token: String)
	case musicUserToken(token: String)

    var headerString: String {
        switch self {
        case .basic(let username, let password):
            let loginString = String(format: "%@:%@", username, password)
            let loginDataString = loginString.data(using: .utf8)!.base64EncodedString()
            return "Basic \(loginDataString)"
        case .raw(let string):
            return string
        case .bearer(let token):
            return "Bearer \(token)"
		case .musicUserToken(let token):
			return token
        }
    }

	var headerField: NetworkRequestHeaderField {
		if case .musicUserToken = self {
			return NetworkRequestHeaderField(name: "Music-User-Token", value: headerString)
		} else {
			return NetworkRequestHeaderField(name: "Authorization", value: headerString)
		}
	}

}
