//
//  URLRequestMockStore.swift
//  HPNetwork
//
//  Created by Henrik Panhans on 23.07.25.
//

import Foundation
import Synchronization

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
public final class URLRequestMockStore: Sendable {

    // MARK: - Properties

    public static let shared = URLRequestMockStore()
    private let mockedURLRequests = Mutex([URLRequestFilter]())

    // MARK: - URLRequest

    public func mockRequests(
        for urlRequest: @escaping @Sendable (URLRequest) -> Bool = { _ in true },
        handler: @escaping @Sendable (URLRequest) -> (Data, URLResponse)
    ) {
        let filter = URLRequestFilter(matchClosure: urlRequest, transformClosure: handler)
        mockedURLRequests.withLock { requests in
            requests.append(filter)
        }
    }

    func mockedRequest(for request: URLRequest) -> URLRequestFilter? {
        mockedURLRequests.withLock { requests in
            requests.first { filter in
                filter.matches(request)
            }
        }
    }

}
