import Foundation
import Testing

@testable import HPNetwork

@Suite struct NetworkRequestTests {

    @Test func networkRequest_HasAuthorizationHeaderField_WhenSpecified() throws {
        let request = BasicDataRequest(
            url: URL(string: "https://google.com"),
            authorization: BasicAuthorization(username: "henrik", password: "admin")
        )
        let urlRequest = try request.makeRequest()
        #expect(urlRequest.allHTTPHeaderFields?["Authorization"] != nil)
    }

    @Test func networkRequest_ThrowsError_WhenURLIsNil() throws {
        let request = FaultyRequest()
        #expect(throws: (any Error).self) {
            try request.makeRequest()
        }
    }

}
