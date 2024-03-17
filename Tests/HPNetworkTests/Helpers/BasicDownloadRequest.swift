import Foundation
import HPNetwork

struct BasicDownloadRequest: DownloadRequest {

    let url: URL?
    let requestMethod: HTTPRequest.Method
    let authorization: (any Authorization)?
    let headerFields: [HTTPField]

    init(
        url: URL?,
        requestMethod: HTTPRequest.Method = .get,
        authorization: (any Authorization)? = nil,
        @HTTPFieldBuilder headerFields: () -> [HTTPField] = { [] }
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
