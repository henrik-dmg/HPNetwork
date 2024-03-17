import Foundation
import HPNetwork

enum URLError: Error {
    case urlNil
}

struct BasicDataRequest: DataRequest {

    typealias Output = Data
    let url: URL?
    let requestMethod: HTTPRequest.Method
    let authorization: (any Authorization)?
    let headerFields: [HTTPField]

    init(
        url: URL?,
        requestMethod: HTTPRequest.Method = .get,
        authorization: (any Authorization)? = nil,
        @HTTPFieldsBuilder headerFields: () -> [HTTPField] = { [] }
    ) {
        self.url = url
        self.requestMethod = requestMethod
        self.authorization = authorization
        self.headerFields = headerFields()
    }

    func makeURL() throws -> URL {
        guard let url else {
            throw URLError.urlNil
        }
        return url
    }

}
