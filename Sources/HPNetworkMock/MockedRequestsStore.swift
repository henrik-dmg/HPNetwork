//
//  MockedRequestsStore.swift
//  HPNetwork
//
//  Created by Henrik Panhans on 22.07.25.
//

import Foundation

@testable import HPNetwork

/// Stores all mutable state for NetworkClientMock, ensuring thread safety.
actor MockedRequestsStore {

    // MARK: - Properties

    private var mockedRequests: [String: any MockedRequest] = [:]

    // MARK: - Methods

    func removeAllMocks() {
        mockedRequests.removeAll()
    }

    func mockRequest<Request: NetworkRequest>(ofType type: Request.Type, handler: @escaping (Request) async throws -> Request.Output) {
        let typeName = String(describing: type.self)
        mockedRequests[typeName] = NetworkClientMock.ConcreteMockedRequest(handler: handler)
    }

    /// Handles the mock request internally and returns the output or nil if not found.
    func handleMockedRequest<Request: NetworkRequest>(for request: Request) async throws -> Request.Output? where Request.Output: Sendable {
        let typeName = String(describing: Request.self)
        guard let concrete = mockedRequests[typeName] as? NetworkClientMock.ConcreteMockedRequest<Request> else {
            return nil
        }
        return try await concrete.handler(request)
    }

}
