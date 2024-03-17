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

    func testBasicRequest_Async_Mocked() async throws {
        networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, 32)
    }

    func testBasicRequest_Async_Unmocked() async throws {
        let request = BasicDecodableRequest<Int>(url: url)
        do {
            _ = try await networkClient.response(request, delegate: nil)
            XCTFail("Request should not succeed")
        } catch {
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    func testBasicRequest_Result_Mocked() async throws {
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

    func testBasicRequest_Result_Unmocked() async throws {
        let request = BasicDecodableRequest<Int>(url: url)
        switch await networkClient.result(request) {
        case .success:
            XCTFail("Request should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    func testBasicRequest_Completion_Mocked() async throws {
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

    func testBasicRequest_Completion_Unmocked() async throws {
        let request = BasicDecodableRequest<Int>(url: url)
        let expection = XCTestExpectation(description: "Networking finished")
        _ = networkClient.schedule(request) { result in
            expection.fulfill()
            switch result {
            case .success:
                XCTFail("Request should not succeed")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
            }
        }
        await fulfillment(of: [expection], timeout: 10)
    }

    func testNetworkClientMock_RemovesAllMocks() async throws {
        networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, 32)

        networkClient.removeAllMocks()

        do {
            _ = try await networkClient.response(request, delegate: nil)
            XCTFail("Request should not succeed after mock is removed")
        } catch {
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

}
