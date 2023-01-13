import Foundation

public extension URLResponse {

    func urlError() -> URLError? {
        guard let httpResponse = self as? HTTPURLResponse else {
            return nil
        }

        switch httpResponse.statusCode {
        case 200...299:
            return nil
        default:
            let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
            return URLError(errorCode)
        }
    }

}
