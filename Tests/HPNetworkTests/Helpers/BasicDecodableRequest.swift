import Foundation
import HPNetwork

// periphery:ignore
struct BasicDecodableRequest<Output: Decodable>: DecodableRequest {

    let url: URL?
    let requestMethod: HTTPRequest.Method = .get

    var decoder: JSONDecoder {
        JSONDecoder()
    }

    var headerFields: [HTTPField] {
        HTTPField.accept(.applicationJSON)
        HTTPField.contentType(.applicationJSON)
    }

    func makeURL() throws -> URL {
        guard let url else {
            throw URLError.urlNil
        }
        return url
    }

}
