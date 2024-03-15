import Foundation
import HTTPTypes

public enum ContentType: String {
    case applicationJSON = "application/json"
}

public extension HTTPField {

    static func contentType(_ type: ContentType) -> HTTPField {
        HTTPField(name: .contentType, value: type.rawValue)
    }

    static func accept(_ type: ContentType) -> HTTPField {
        HTTPField(name: .accept, value: type.rawValue)
    }

}
