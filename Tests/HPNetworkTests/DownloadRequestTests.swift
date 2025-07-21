import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class DownloadRequestTests: XCTestCase {

    // MARK: - Properties

    private lazy var networkClient = NetworkClient(urlSession: mockedURLSession)
    private lazy var mockedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSessionMock.self]
        return URLSession(configuration: configuration)
    }()

    private let url = URL(string: "https://ipapi.co/json")!
    private let jsonString = "{}"
    private var fileURL: URL?

    // MARK: - Test Lifecycle

    override func tearDownWithError() throws {
        if let fileURL {
            try FileManager.default.removeItem(at: fileURL)
        }
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func testBasicRequest_Async() async throws {
        mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        fileURL = response.output
        let downloadedContents = try String(contentsOf: response.output)
        XCTAssertEqual(downloadedContents, jsonString)
    }

    func testBasicRequest_Result() async throws {
        mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        switch await networkClient.result(request) {
        case .success(let response):
            fileURL = response.output
            let downloadedContents = try String(contentsOf: response.output)
            XCTAssertEqual(downloadedContents, jsonString)
        case .failure(let error):
            throw error
        }
    }

    func testBasicRequest_Completion() async throws {
        mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        let response = try await networkClient.schedule(request).value
        let downloadedContents = try String(contentsOf: response.output)
        XCTAssertEqual(downloadedContents, jsonString)
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
