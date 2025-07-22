import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

class NetworkClientMockTests: XCTestCase {

    // MARK: - Properties

    let url = URL(string: "https://ipapi.co/json")!

    // MARK: - Tests

    func testBasicRequest_Async_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, 32)
    }

    func testBasicRequest_Async_Unmocked() async throws {
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        do {
            _ = try await networkClient.response(request, delegate: nil)
            XCTFail("Request should not succeed")
        } catch {
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    func testBasicRequest_Result_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
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
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        switch await networkClient.result(request) {
        case .success:
            XCTFail("Request should not succeed")
        case .failure(let error):
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    func testBasicRequest_Completion_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.schedule(request).value
        XCTAssertEqual(response.output, 32)
    }

    func testBasicRequest_Completion_Unmocked() async throws {
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        do {
            _ = try await networkClient.schedule(request).value
            XCTFail("Request should not succeed")
        } catch {
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    func testNetworkClientMock_RemovesAllMocks() async throws {
        let networkClient = await makeNetworkClient()

        await networkClient.mockRequest(ofType: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, 32)

        await networkClient.removeAllMocks()

        do {
            _ = try await networkClient.response(request, delegate: nil)
            XCTFail("Request should not succeed after mock is removed")
        } catch {
            XCTAssertEqual(error as? NetworkClientMockError, .noMockConfiguredForRequest)
        }
    }

    // MARK: - Helpers

    private func makeNetworkClient() async -> NetworkClientMock {
        NetworkClientMock(urlSession: .shared, fallbackToURLSessionIfNoMatchingMock: false)
    }

}
