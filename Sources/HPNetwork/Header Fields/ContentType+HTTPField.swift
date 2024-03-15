import Foundation
import HTTPTypes

public enum ContentType: String {
    case applicationJSON = "application/json"
}

extension HTTPField {

    public static func contentType(_ type: ContentType) -> HTTPField {
        HTTPField(name: .contentType, value: type.rawValue)
    }

    public static func accept(_ type: ContentType) -> HTTPField {
        HTTPField(name: .accept, value: type.rawValue)
    }

}
