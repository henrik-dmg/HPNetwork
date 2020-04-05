import XCTest
@testable import HPNetwork

final class HPNetworkTests: XCTestCase {

    func testRequest() {
        let request = NetworkRequest<Int>(url: "https://google.com", method: .get)

        Network.shared.send(request) { result in
            switch result {
            case .success(let test):
                print(test)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

    }

}
