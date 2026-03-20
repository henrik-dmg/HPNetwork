import Foundation
import Testing

@testable import HPNetwork
@testable import HPNetworkMock

@Suite(.serialized) struct NetworkClientMockTests {

    // MARK: - Properties

    let url: URL

    init() async throws {
        url = try #require(URL(string: "https://ipapi.co/json"))
        await NetworkRequestMockStore.shared.removeAllMocks()
    }

    // MARK: - Tests

    @Test func basicRequest_Async_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await NetworkRequestMockStore.shared.mockRequests(for: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        #expect(response.output == 32)
    }

    @Test func basicRequest_Async_Unmocked() async throws {
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        await #expect(throws: NetworkClientMockError.noMockConfiguredForRequest) {
            _ = try await networkClient.response(request, delegate: nil)
        }
    }

    @Test func basicRequest_Result_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await NetworkRequestMockStore.shared.mockRequests(for: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.result(request).get()
        #expect(response.output == 32)
    }

    @Test func basicRequest_Result_Unmocked() async throws {
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        let result = await networkClient.result(request)
        #expect(throws: NetworkClientMockError.noMockConfiguredForRequest) {
            try result.get()
        }
    }

    @Test func basicRequest_Completion_Mocked() async throws {
        let networkClient = await makeNetworkClient()

        await NetworkRequestMockStore.shared.mockRequests(for: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.schedule(request).value
        #expect(response.output == 32)
    }

    @Test func basicRequest_Completion_Unmocked() async throws {
        let networkClient = await makeNetworkClient()

        let request = BasicDecodableRequest<Int>(url: url)
        await #expect(throws: NetworkClientMockError.noMockConfiguredForRequest) {
            _ = try await networkClient.schedule(request).value
        }
    }

    @Test func networkClientMock_RemovesAllMocks() async throws {
        let networkClient = await makeNetworkClient()

        await NetworkRequestMockStore.shared.mockRequests(for: BasicDecodableRequest<Int>.self) { _ in
            32
        }

        let request = BasicDecodableRequest<Int>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        #expect(response.output == 32)

        await NetworkRequestMockStore.shared.removeAllMocks()

        await #expect(throws: NetworkClientMockError.noMockConfiguredForRequest) {
            _ = try await networkClient.response(request, delegate: nil)
        }
    }

    // MARK: - Helpers

    private func makeNetworkClient() async -> NetworkClientMock {
        NetworkClientMock(urlSession: .shared, fallbackToURLSessionIfNoMatchingMock: false)
    }

}
