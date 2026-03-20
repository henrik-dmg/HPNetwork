import Foundation
import Testing

@testable import HPNetwork
@testable import HPNetworkMock

@Suite(.serialized) struct DataRequestTests {

    // MARK: - Properties

    let url: URL

    init() throws {
        url = try #require(URL(string: "https://ipapi.co/json"))
    }

    // MARK: - Tests

    @Test func basicRequest_Async() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        #expect(response.output == EmptyStruct())
    }

    @Test func basicRequest_Result() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.result(request).get()
        #expect(response.output == EmptyStruct())
    }

    @Test func basicRequest_Completion() async throws {
        guard #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) else { return }
        let networkClient = makeNetworkClient()
        try mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.schedule(request).value
        #expect(response.output == EmptyStruct())
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

private struct EmptyStruct: Codable, Equatable {}
