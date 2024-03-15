import Foundation
import HPNetwork
import HTTPTypes

struct BasicDataRequest: DataRequest {

    typealias Output = Data
    let url: URL?
    let requestMethod: HTTPRequest.Method = .get

    func makeURL() throws -> URL {
        guard let url else {
            throw URLError.urlNil
        }
        return url
    }

}
