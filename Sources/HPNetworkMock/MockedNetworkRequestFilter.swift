//
//  MockedNetworkRequestFilter.swift
//  HPNetwork
//
//  Created by Henrik Panhans on 23.07.25.
//

import Foundation
import HPNetwork
import Synchronization

protocol MockedRequestFilterProtocol: Sendable {

    associatedtype Input
    associatedtype Output

    func matches(_ input: Input) -> Bool
    func transform(_ input: Input) throws -> Output

}

protocol MockedNetworkRequestFilterProtocol: MockedRequestFilterProtocol where Input: NetworkRequest {

    associatedtype Output = Input.Output

}

struct NetworkRequestFilter<Request: NetworkRequest>: MockedNetworkRequestFilterProtocol {

    typealias Input = Request

    let matchClosure: @Sendable (Input) -> Bool
    let transformClosure: @Sendable (Input) throws -> Output

    func matches(_ input: Input) -> Bool {
        matchClosure(input)
    }

    func transform(_ input: Input) throws -> Output {
        try transformClosure(input)
    }

}

struct URLRequestFilter: MockedRequestFilterProtocol {

    typealias Input = URLRequest
    typealias Output = (Data, URLResponse)

    let matchClosure: @Sendable (Input) -> Bool
    let transformClosure: @Sendable (Input) throws -> Output

    func matches(_ input: Input) -> Bool {
        matchClosure(input)
    }

    func transform(_ input: Input) throws -> Output {
        try transformClosure(input)
    }

}
