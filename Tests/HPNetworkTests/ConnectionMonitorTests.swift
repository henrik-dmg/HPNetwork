import Foundation
import Network
import XCTest

@testable import HPNetwork

final class ConnectionMonitorTests: XCTestCase {

    func testConnectionMonitor_StartsMonitoring() async throws {
        let monitor = ConnectionMonitor()
        try await Task.sleep(nanoseconds: 1_000_000)

        let expection = XCTestExpectation(description: "Networking finished")
        _ = monitor.$currentPath.sink { path in
            expection.fulfill()
        }
        await fulfillment(of: [expection], timeout: 10)
    }

}
