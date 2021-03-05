import Foundation

public enum NetworkRequestAuthentication {

    case basic(username: String, password: String)
    case raw(string: String)
    case bearer(token: String)

    var headerString: String? {
        switch self {
        case .basic(let username, let password):
            let loginString = String(format: "%@:%@", username, password)
			guard let loginDataString = loginString.data(using: .utf8)?.base64EncodedString() else {
				return nil
			}
            return "Basic \(loginDataString)"
        case .raw(let string):
            return string
        case .bearer(let token):
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
