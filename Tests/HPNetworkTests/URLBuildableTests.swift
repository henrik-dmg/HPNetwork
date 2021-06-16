@testable import HPNetwork
import XCTest

class URLBuildableTests: XCTestCase {

	func testBuildBasicURL() throws {
		let url = URL.build {
			Scheme("https")
			Host("apple.com")
			Path("/products/iphone")
			PathComponent("old")
		}

		let unwrappedURL = try XCTUnwrap(url)
		XCTAssertEqual(unwrappedURL.absoluteString, "https://apple.com/products/iphone/old")
	}

}
