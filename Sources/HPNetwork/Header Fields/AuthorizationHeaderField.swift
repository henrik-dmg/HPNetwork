import Foundation

public struct AuthorizationHeaderField: HeaderField {

    public var name: String {
        "Authorization"
    }

    public let value: String?

    public init(_ authorization: Authorization) {
        value = authorization.headerString
    }

}
