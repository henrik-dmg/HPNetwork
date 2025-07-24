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
        guard let mockedRequest = URLRequestMockStore.shared.mockedRequest(for: request) else {
            XCTFail("No mocked request configured for url \"\(request)\"")
            client?.urlProtocol(self, didFailWithError: URLSessionMockError.noMockedRequest)
            return
        }

        do {
            let (data, response) = try mockedRequest.transform(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            XCTFail("No response returned for url \"\(request)\"")
        }
    }

    public override func stopLoading() {}

}
