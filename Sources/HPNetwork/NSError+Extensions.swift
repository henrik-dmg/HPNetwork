import Foundation

extension NSError {

    func withDescription(_ message: String) -> NSError {
        var dict = userInfo
        dict[NSLocalizedDescriptionKey] = message
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    convenience init(domain: String = "com.henrikpanhans.HPNetwork", code: Int = 1, description: String) {
        let dictionary = [NSLocalizedDescriptionKey: description]
        self.init(domain: domain, code: code, userInfo: dictionary)
    }

    static let unknown = NSError(code: 1, description: "Unknown error")

}
