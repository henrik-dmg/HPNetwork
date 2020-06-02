@testable import HPNetwork
import XCTest

class NetworkTests: XCTestCase {

    func testSimpleRequest() {
        let expectation = XCTestExpectation(description: "fetched from server")

        let request = DecodableRequest<EmptyStruct>(urlString: "https://ipapi.co/json")

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)
    }

}

struct EmptyStruct: Codable {
}
