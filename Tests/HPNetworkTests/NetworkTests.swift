import XCTest

@testable import HPNetwork

@available(iOS 15.0, macOS 12.0, *)
class NetworkTests: XCTestCase {

    func testSimpleRequest() async {
        let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))
        await HPAssertNoThrow(try await request.response())
    }

    func testSimpleRequestCompletionHandler() async {
        let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))

        let expectiona = XCTestExpectation(description: "Networking finished")

        request.schedule { _ in
            expectiona.fulfill()
        }

        wait(for: [expectiona], timeout: 10)
    }

    func testPublisher() {
        let expectationFinished = expectation(description: "finished")
        let expectationReceive = expectation(description: "receiveValue")

        let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))

        let cancellable = request.dataTaskPublisher().sink { result in
            switch result {
            case let .failure(error):
                XCTFail(error.localizedDescription)
            case .finished:
                expectationFinished.fulfill()
            }
        } receiveValue: { _ in
            expectationReceive.fulfill()
        }

        waitForExpectations(timeout: 10) { _ in
            cancellable.cancel()
        }
    }

    func testPublisherFailure() {
        let expectationFinished = expectation(description: "finished")

        let request = FaultyRequest()

        let cancellable = request.dataTaskPublisher().sink { result in
            switch result {
            case let .failure(error as NSError):
                XCTAssertEqual(error, NSError.failedToCreateRequest.withFailureReason("The URL instance to create the request is nil"))
                expectationFinished.fulfill()
            case .finished:
                XCTFail("Networking should not be successful")
            }
        } receiveValue: { _ in
            //
        }

        waitForExpectations(timeout: 10) { _ in
            cancellable.cancel()
        }
    }

}

struct BasicDecodableRequest<Output: Decodable>: DecodableRequest {

    let url: URL?
    let requestMethod: RequestMethod = .get

    var decoder: JSONDecoder {
        JSONDecoder()
    }

    var headerFields: [HeaderField] {
        RawHeaderField.acceptJSON
        ContentTypeHeaderField.json
    }

    func makeURL() throws -> URL {
        guard let url = url else {
            throw NSError.failedToCreateRequest
        }
        return url
    }

}

struct BasicRequest: DataRequest {

    typealias Output = Data
    let url: URL?
    var finishingQueue: DispatchQueue
    let requestMethod: RequestMethod = .get

    func makeURL() throws -> URL {
        guard let url = url else {
            throw NSError.failedToCreateRequest
        }
        return url
    }

}

struct FaultyRequest: DataRequest {

    typealias Output = Data

    var requestMethod: RequestMethod {
        .get
    }

    func makeURL() throws -> URL {
        throw NSError.failedToCreateRequest.withFailureReason("The URL instance to create the request is nil")
    }

}

struct EmptyStruct: Codable {}
