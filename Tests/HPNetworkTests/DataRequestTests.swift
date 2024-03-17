import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

final class DataRequestTests: XCTestCase {

    // MARK: - Properties

    let url = URL(string: "https://ipapi.co/json")!

    lazy var mockedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSessionMock.self]
        return URLSession(configuration: configuration)
    }()

    lazy var networkClient = NetworkClient(urlSession: mockedURLSession)

    // MARK: - Test Lifecycle

    override func tearDown() {
        URLSessionMock.unregisterAllMockedRequests()
        super.tearDown()
    }

    // MARK: - Tests

    func testBasicRequest_Async() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, EmptyStruct())
    }

    func testBasicRequest_Result() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        switch await networkClient.result(request) {
        case .success(let response):
            XCTAssertEqual(response.output, EmptyStruct())
        case .failure(let error):
            throw error
        }
    }

    func testBasicRequest_Completion() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let expection = XCTestExpectation(description: "Networking finished")
        _ = networkClient.schedule(request) { result in
            expection.fulfill()
            switch result {
            case .success(let response):
                XCTAssertEqual(response.output, EmptyStruct())
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        await fulfillment(of: [expection], timeout: 10)
    }

    // MARK: - Helpers

    private func mockNetworkRequest(url: URL, dataToReturn data: Data?) {
        _ = URLSessionMock.mockRequest(to: url, ignoresQuery: false) { _ in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": ContentType.applicationJSON.rawValue]
            )!
            return (data ?? Data(), response)
        }
    }

}

private struct EmptyStruct: Codable, Equatable {}
