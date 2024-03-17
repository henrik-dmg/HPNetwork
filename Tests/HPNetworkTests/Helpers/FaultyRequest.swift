import Foundation
import HPNetwork

struct FaultyRequest: DataRequest {

    typealias Output = Data

    let requestMethod: HTTPRequest.Method = .get

    func makeURL() throws -> URL {
        throw URLError.urlNil
    }

}
