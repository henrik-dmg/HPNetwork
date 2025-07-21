import Foundation
import HPNetwork
import HTTPTypes
import HTTPTypesFoundation
import Synchronization
import XCTest

#if canImport(Testing)
import Testing
#endif

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum URLSessionMockError: Error {
    case cantCreateURL
    case noURL
    case noMockedRequest
}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public final class URLSessionMock: URLProtocol {

    // MARK: - Overridden methods

    public override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    public override func startLoading() {
        guard let url = request.url else {
            XCTFail("URLRequest has no URL")
            client?.urlProtocol(self, didFailWithError: URLSessionMockError.noURL)
            return
        }
        guard let mockedRequest = MockedRequestStore.shared.mockedRequest(for: url) else {
            XCTFail("No mocked request configured for url \"\(url.absoluteString)\"")
            client?.urlProtocol(self, didFailWithError: URLSessionMockError.noMockedRequest)
            return
        }

        do {
            let (data, response) = try mockedRequest.handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            XCTFail("No response returned for url \"\(url.absoluteString)\"")
        }
    }

    public override func stopLoading() {}

}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
final class MockedRequestStore: Sendable {

    // MARK: - Nested Types

    public typealias MockedRequestHandler = @Sendable (URLRequest) throws -> (Data, HTTPURLResponse)

    struct MockedNetworkRequest: Sendable {
        let url: URL
        let ignoresQuery: Bool
        let handler: MockedRequestHandler
        let id = UUID()
    }

    // MARK: - Properties

    static let shared = MockedRequestStore()

    private let mockedRequests = Mutex([UUID: MockedNetworkRequest]())

    // MARK: - Registering Mocks

    @discardableResult
    public func mockRequest(
        to url: URL,
        ignoresQuery: Bool,
        handler: @escaping MockedRequestHandler
    ) -> UUID {
        let mockedRequest = MockedNetworkRequest(url: url, ignoresQuery: ignoresQuery, handler: handler)
        mockedRequests.withLock { requests in
            requests[mockedRequest.id] = mockedRequest
        }
        return mockedRequest.id
    }

    @discardableResult
    public func mockRequest(
        to urlString: String,
        ignoresQuery: Bool,
        handler: @escaping MockedRequestHandler
    ) throws -> UUID {
        guard let url = URL(string: urlString) else {
            throw URLSessionMockError.cantCreateURL
        }
        return mockRequest(to: url, ignoresQuery: ignoresQuery, handler: handler)
    }

    public func unregisterMockedRequest(with id: UUID) {
        mockedRequests.withLock { requests in
            requests[id] = nil
        }
    }

    public func unregisterAllMockedRequests() {
        mockedRequests.withLock { requests in
            requests.removeAll()
        }
    }

    func mockedRequest(for url: URL) -> MockedNetworkRequest? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        urlComponents.query = nil
        let urlWithoutQuery = urlComponents.url

        return mockedRequests.withLock { requests in
            requests.values.first { request in
                if request.url == url {
                    return true
                } else if request.ignoresQuery, let urlWithoutQuery {
                    return request.url == urlWithoutQuery
                }
                return false
            }
        }
    }

}
