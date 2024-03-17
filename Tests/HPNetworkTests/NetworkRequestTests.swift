import XCTest

@testable import HPNetwork

final class NetworkRequestTests: XCTestCase {

    func testNetworkRequest_HasAuthorizationHeaderField_WhenSpecified() throws {
        let request = BasicDataRequest(
            url: URL(string: "https://google.com"),
            authorization: BasicAuthorization(username: "henrik", password: "admin")
        )
        let urlRequest = try request.makeRequest()
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields?["Authorization"])
    }

}
