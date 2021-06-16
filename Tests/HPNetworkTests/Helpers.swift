import Foundation
import XCTest

func HPAssertNoThrow<T>(_ expression: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async {
	do {
		_ = try await expression()
	} catch let error {
		XCTFail(error.localizedDescription)
	}
}
