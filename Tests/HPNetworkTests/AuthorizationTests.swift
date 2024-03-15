@testable import HPNetwork
import XCTest

final class AuthorizationTests: XCTestCase {

    func testBasicAuthorization() throws {
        let auth = BasicAuthorization(username: "henrik", password: "admin")
        let encodedString = try XCTUnwrap("henrik:admin".data(using: .utf8)?.base64EncodedString())
        let expectedString = "Basic \(encodedString)"
        XCTAssertEqual(auth?.headerString, expectedString)
    }

    func testBearerAuthorization() {
        let auth = BearerAuthorization("someToken")
        XCTAssertEqual(auth.headerString, "Bearer someToken")
    }

}
