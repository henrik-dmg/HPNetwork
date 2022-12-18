import Foundation

public struct BearerAuthorization: Authorization {

    public let headerString: String

    public init(_ bearerToken: String) {
        headerString = "Bearer \(bearerToken)"
    }

}
