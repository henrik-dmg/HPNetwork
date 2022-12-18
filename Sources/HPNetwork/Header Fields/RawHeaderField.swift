import Foundation

public struct RawHeaderField: HeaderField {

    public let name: String
    public let value: String?

    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }

}

public extension RawHeaderField {

    /// A header field specifying `application/json` as accepted content type
    static var acceptJSON: HeaderField {
        Self(name: "Accept", value: "application/json")
    }

    /// A header field specifying `utf-8` as accepted character set
    static var acceptCharsetUTF8: HeaderField {
        Self(name: "Accept-Charset", value: "utf-8")
    }

}
