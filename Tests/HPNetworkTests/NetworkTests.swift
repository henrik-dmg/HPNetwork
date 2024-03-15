import HTTPTypes
import XCTest

@testable import HPNetwork

enum URLError: LocalizedError {
    case urlNil
}

@available(iOS 15.0, macOS 12.0, *)
class NetworkTests: XCTestCase {

    func testSimpleRequest() async {
        let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))
        await HPAssertNoThrow(try await request.response())
    }

    func testFaultyRequest() {
        let request = FaultyRequest()
        XCTAssertThrowsError(try request.makeURL())
    }

    func testSimpleRequestCompletionHandler() async {
        let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))

        let expectiona = XCTestExpectation(description: "Networking finished")

        request.schedule { _ in
            expectiona.fulfill()
        }

        await fulfillment(of: [expectiona], timeout: 10)
    }

}

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
        guard let url = url else {
            throw URLError.urlNil
        }
        return url
    }

}

struct BasicRequest: DataRequest {

    typealias Output = Data
    let url: URL?
    var finishingQueue: DispatchQueue
    let requestMethod: HTTPRequest.Method = .get

    func makeURL() throws -> URL {
        guard let url else {
            throw URLError.urlNil
        }
        return url
    }

}

struct FaultyRequest: DataRequest {

    typealias Output = Data

    var requestMethod: HTTPRequest.Method {
        .get
    }

    func makeURL() throws -> URL {
        throw URLError.urlNil
    }

}

struct EmptyStruct: Codable {}
