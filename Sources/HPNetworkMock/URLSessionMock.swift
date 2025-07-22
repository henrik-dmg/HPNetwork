import Foundation
import HTTPTypes
import HTTPTypesFoundation
import Synchronization
import XCTest

#if canImport(Testing)
import Testing
#endif

/// An error that can be thrown by ``URLSessionMock``.
@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public enum URLSessionMockError: Error {
    case cantCreateURL
    case noURL
    case noMockedRequest
}

/// A class that can be used to mock and handle network requests.
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
