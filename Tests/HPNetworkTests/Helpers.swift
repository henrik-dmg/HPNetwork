import Foundation
import XCTest

func HPAssertNoThrow<T>(
    _ expression: @autoclosure () async throws -> T,
    _: @autoclosure () -> String = "",
    file _: StaticString = #filePath,
    line _: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTFail(error.localizedDescription)
    }
}
