import Foundation
import HPNetwork
import HTTPTypes
import HTTPTypesFoundation
import XCTest

public enum URLSessionMockError: Error {
    case cantCreateURL
    case noURL
    case noMockedRequest
}

public final class URLSessionMock: URLProtocol {

    // MARK: - Nested Types

    private struct MockedNetworkRequest {
        let url: URL
        let ignoresQuery: Bool
        let handler: (URLRequest) throws -> (Data, HTTPURLResponse)
        let id = UUID()
    }

    // MARK: - Properties

    private static var mockedRequests: [UUID: MockedNetworkRequest] = [:]

    // MARK: - Registering Mocks

    @discardableResult
    public static func mockRequest(to url: URL, ignoresQuery: Bool, handler: @escaping (URLRequest) throws -> (Data, HTTPURLResponse))
        -> UUID
    {
        let mockedRequest = MockedNetworkRequest(url: url, ignoresQuery: ignoresQuery, handler: handler)
        mockedRequests[mockedRequest.id] = mockedRequest
        return mockedRequest.id
    }

    @discardableResult
    public static func mockRequest(
        to urlString: String,
        ignoresQuery: Bool,
        handler: @escaping (URLRequest) throws -> (Data, HTTPURLResponse)
    ) throws -> UUID {
        guard let url = URL(string: urlString) else {
            throw URLSessionMockError.cantCreateURL
        }
        return mockRequest(to: url, ignoresQuery: ignoresQuery, handler: handler)
    }

    public static func unregisterMockedRequest(with id: UUID) {
        mockedRequests[id] = nil
    }

    public static func unregisterAllMockedRequests() {
        mockedRequests.removeAll()
    }

    private static func mockedRequest(for url: URL) -> MockedNetworkRequest? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        urlComponents.query = nil
        let urlWithoutQuery = urlComponents.url

        return mockedRequests.values.first { request in
            if request.url == url {
                return true
            } else if request.ignoresQuery, let urlWithoutQuery {
                return request.url == urlWithoutQuery
            }
            return false
        }
    }

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
        guard let mockedRequest = Self.mockedRequest(for: url) else {
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
