import Foundation
import Testing

@testable import HPNetwork
@testable import HPNetworkMock

@Suite(.serialized) class DownloadRequestTests {

    // MARK: - Properties

    private let url: URL
    private let jsonString = "{}"
    private var fileURL: URL?

    // MARK: - Test Lifecycle

    init() throws {
        url = try #require(URL(string: "https://ipapi.co/json"))
    }

    deinit {
        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    // MARK: - Tests

    @Test func basicRequest_Async() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        fileURL = response.output
        let downloadedContents = try String(contentsOf: response.output)
        #expect(downloadedContents == jsonString)
    }

    @Test func basicRequest_Result() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        let response = try await networkClient.result(request).get()
        fileURL = response.output
        let downloadedContents = try String(contentsOf: response.output)
        #expect(downloadedContents == jsonString)
    }

    @Test func basicRequest_Completion() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: jsonString.data(using: .utf8))

        let request = BasicDownloadRequest(url: url)
        let response = try await networkClient.schedule(request).value
        let downloadedContents = try String(contentsOf: response.output)
        #expect(downloadedContents == jsonString)
    }

    // MARK: - Helpers

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    private func makeNetworkClient() -> NetworkClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLSessionMock.self]
        return NetworkClient(urlSession: URLSession(configuration: configuration))
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    private func mockNetworkRequest(url: URL, dataToReturn data: Data?) throws {
        let response = try #require(
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": ContentType.applicationJSON.rawValue]
            )
        )
        URLRequestMockStore.shared.mockRequests { request in
            request.url == url
        } handler: { _ in
            (data ?? Data(), response)
        }
    }

}
