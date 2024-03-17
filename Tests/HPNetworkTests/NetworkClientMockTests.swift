import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

class NetworkClientMockTests: XCTestCase {

    // MARK: - Properties

    let url = URL(string: "https://ipapi.co/json")!

    lazy var networkClient: NetworkClientMock = {
        let client = NetworkClientMock()
        client.fallbackToURLSessionIfNoMatchingMock = false
        return client
    }()

    // MARK: - Tests

    func testBasicRequest_Async() async throws {
        networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, 32)
    }

    func testBasicRequest_Result() async throws {
        networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        switch await networkClient.result(request) {
        case .success(let response):
            XCTAssertEqual(response.output, 32)
        case .failure(let error):
            throw error
        }
    }

    func testBasicRequest_Completion() async throws {
        networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let expection = XCTestExpectation(description: "Networking finished")
        _ = networkClient.schedule(request) { result in
            expection.fulfill()
            switch result {
            case .success(let response):
                XCTAssertEqual(response.output, 32)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        await fulfillment(of: [expection], timeout: 10)
    }

}
