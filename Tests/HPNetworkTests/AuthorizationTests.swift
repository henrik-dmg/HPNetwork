import Testing

@testable import HPNetwork

@Suite struct AuthorizationTests {

    @Test func basicAuthorization() throws {
        let auth = BasicAuthorization(username: "henrik", password: "admin")
        let encodedString = try #require("henrik:admin".data(using: .utf8)?.base64EncodedString())
        let expectedString = "Basic \(encodedString)"
        #expect(auth?.headerString == expectedString)
    }

    @Test func bearerAuthorization() {
        let auth = BearerAuthorization("someToken")
        #expect(auth.headerString == "Bearer someToken")
    }

}
