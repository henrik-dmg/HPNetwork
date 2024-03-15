import Foundation
import HPNetwork
import HTTPTypes
import HTTPTypesFoundation
import XCTest

public struct MockedNetworkRequest: CustomStringConvertible {
    let urlString: String
    let ignoresQuery: Bool
    let handler: (URLRequest) throws -> (Data, HTTPURLResponse)
    let id = UUID()

    public var description: String {
        "MockedRequest(\(urlString), ignoresQuery: \(ignoresQuery), id: \(id.uuidString)"
    }
}

open class NetworkRequestMock: URLProtocol {

    // MARK: - Properties

    private static var mockedRequests: [MockedNetworkRequest] = []

    // MARK: - Registering Mocks

    public static func register(_ mockedRequest: MockedNetworkRequest) {
        mockedRequests.append(mockedRequest)
    }

    static func mockedRequest(for url: URL) -> MockedNetworkRequest? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        urlComponents.query = nil
        guard let urlWithoutQuery = urlComponents.url else {
            return nil
        }
        return mockedRequests.first { request in
            if request.urlString == url.absoluteString {
                return true
            } else if request.ignoresQuery {
                return request.urlString == urlWithoutQuery.absoluteString
            }
            return false
        }
    }

    static func removeAllMocks() {
        mockedRequests.removeAll()
    }

    // MARK: - Overridden methods

    open override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    open override func startLoading() {
        guard let url = request.url else {
            XCTFail("URLRequest has no URL")
            return
        }
        guard let mockedRequest = Self.mockedRequest(for: url) else {
            XCTFail("No mocked request configured for url \"\(url.absoluteString)\"")
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

    open override func stopLoading() {}

}
