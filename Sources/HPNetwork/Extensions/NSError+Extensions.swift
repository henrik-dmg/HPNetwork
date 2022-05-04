import Foundation

extension NSError {

    public static let hpCodableDataKey = "hpCodableDataKey"

    func withDescription(_ message: String) -> NSError {
        var dict = userInfo
        dict[NSLocalizedDescriptionKey] = message
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    func withFailureReason(_ reason: String) -> NSError {
        var dict = userInfo
        dict[NSLocalizedFailureReasonErrorKey] = reason
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    func injectJSON(_ data: Data) -> NSError {
        let jsonString = data.prettyPrintedJSONString

        var dict = userInfo
        dict[NSError.hpCodableDataKey] = jsonString
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    convenience init(domain: String = "com.henrikpanhans.HPNetwork", code: Int = 1, description: String) {
        let dictionary = [NSLocalizedDescriptionKey: description]
        self.init(domain: domain, code: code, userInfo: dictionary)
    }

    static let unknown = NSError(code: 1, description: "Unknown error")
    static let failedToCreateRequest = NSError(code: 42, description: "Failed to create URLRequest")
    static let imageError = NSError(code: 78, description: "Could not convert data to image")
    static let cancelledNetworkOperation = NSError(code: 101, description: "The network operation was cancelled")
    static let urlBuilderFailed = NSError(code: 56, description: "URLBuilder failed to construct the URL")

}

extension Data {

    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else {
            return nil
        }
        return prettyPrintedString
    }

}
