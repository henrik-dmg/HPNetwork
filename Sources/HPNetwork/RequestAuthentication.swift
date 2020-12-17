import Foundation

public enum RequestAuthentication {

    case basic(username: String, password: String)
    case raw(string: String)
    case bearer(token: String)

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
        }
    }

	var headerField: RequestHeaderField {
		RequestHeaderField(name: "Authorization", value: headerString)
	}

}
