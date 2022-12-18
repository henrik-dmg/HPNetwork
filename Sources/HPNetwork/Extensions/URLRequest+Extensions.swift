import Foundation

public extension URLRequest {

    /// Sets all specified header fields on the URL request
    /// - Parameter headerFields: The header fields which should be set on the URL request
    mutating func configureHeaderFields(@HeaderFieldBuilder headerFields: () -> [HeaderField]) {
        headerFields().forEach { headerField in
            addHeaderField(headerField)
        }
    }

    /// Adds a new header field with specified name and value
    /// - Parameter field: The header field that will be added to the request
    mutating func addHeaderField(_ field: HeaderField) {
        setValue(field.value, forHTTPHeaderField: field.name)
    }

}
