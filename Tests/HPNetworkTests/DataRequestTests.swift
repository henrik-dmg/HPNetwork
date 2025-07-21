import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class DataRequestTests: XCTestCase {

    // MARK: - Properties

    let url = URL(string: "https://ipapi.co/json")!

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
        let response = try await networkClient.schedule(request).value
        XCTAssertEqual(response.output, EmptyStruct())
    }

    // MARK: - Helpers

    private func mockNetworkRequest(url: URL, dataToReturn data: Data?) {
        MockedRequestStore.shared.mockRequest(to: url, ignoresQuery: false) { _ in
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
