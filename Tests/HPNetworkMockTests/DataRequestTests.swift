import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class DataRequestTests: XCTestCase {

    // MARK: - Properties

    let url = URL(string: "https://ipapi.co/json")!

    override func setUp() {
        super.setUp()
        URLRequestMockStore.shared.removeAllMocks()
    }

    lazy var mockedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSessionMock.self]
        return URLSession(configuration: configuration)
    }()

    lazy var networkClient = NetworkClient(urlSession: mockedURLSession)

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
        let response = try await networkClient.result(request).get()
        XCTAssertEqual(response.output, EmptyStruct())
    }

    func testBasicRequest_Completion() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.schedule(request).value
        XCTAssertEqual(response.output, EmptyStruct())
    }

    // MARK: - Helpers

    private func mockNetworkRequest(url: URL, dataToReturn data: Data?) {
        URLRequestMockStore.shared.mockRequests { request in
            request.url == url
        } handler: { _ in
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
