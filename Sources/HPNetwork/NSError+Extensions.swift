import Foundation

extension NSError {

    public static let hpCodableDataKey = "hpCodableDataKey"

    func withDescription(_ message: String) -> NSError {
        var dict = userInfo
        dict[NSLocalizedDescriptionKey] = message
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    func injectJSON(_ data: Data) -> NSError {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            return self
        }

        let jsonString = String(data: jsonData, encoding: .utf8)

        var dict = userInfo
        dict[NSError.hpCodableDataKey] = jsonString
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    convenience init(domain: String = "com.henrikpanhans.HPNetwork", code: Int = 1, description: String) {
        let dictionary = [NSLocalizedDescriptionKey: description]
        self.init(domain: domain, code: code, userInfo: dictionary)
    }

    static let unknown = NSError(code: 1, description: "Unknown error")

}
