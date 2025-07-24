//
//  NetworkRequestMockStore.swift
//  HPNetwork
//
//  Created by Henrik Panhans on 23.07.25.
//

import Foundation
import HPNetwork

public final actor NetworkRequestMockStore: Sendable {

    // MARK: - Properties

    public static let shared = NetworkRequestMockStore()
    private var requests: [any MockedNetworkRequestFilterProtocol] = []

    // MARK: - NetworkRequest

    public func mockRequests<Request: NetworkRequest>(
        for type: Request.Type,
        filter: @escaping @Sendable (Request) -> Bool = { _ in true },
        handler: @escaping @Sendable (Request) -> Request.Output
    ) {
        let filter = NetworkRequestFilter(matchClosure: filter, transformClosure: handler)
        requests.append(filter)
    }

    func mockedRequest<Request: NetworkRequest>(for request: Request) -> NetworkRequestFilter<Request>? {
        let mocks = requests.compactMap { mockedRequest in
            mockedRequest as? NetworkRequestFilter<Request>
        }
        return mocks.first { $0.matches(request) }
    }

    // MARK: - Removing

    public func removeAllMocks() {
        requests.removeAll()
    }

}
