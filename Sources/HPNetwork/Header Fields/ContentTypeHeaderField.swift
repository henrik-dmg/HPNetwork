import Foundation

public struct ContentTypeHeaderField: HeaderField {

    public static var json: ContentTypeHeaderField {
        Self("application/json")
    }

    public var name: String {
        "Content-Type"
    }

    public let value: String?

    public init(_ contentType: String) {
        value = contentType
    }

}
