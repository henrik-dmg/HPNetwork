@testable import HPNetwork
import XCTest

class URLQueryItemBuilderTests: XCTestCase {

    func testURL() throws {
		let url = try URLBuilder.buildThrowing {
			Host("api.openweathermap.org")
			PathComponent("data")
			PathComponent("2.5")
			PathComponent("onecall")
			QueryItem(name: "lat", value: 48.123123012, digits: 5)
			QueryItem(name: "lon", value: -12.9123001299, digits: 5)
			QueryItem(name: "appid", value: "apiKey")
			QueryItem(name: "units", value: "metric")
		}

        XCTAssertEqual(url.absoluteString, "https://api.openweathermap.org/data/2.5/onecall?lat=48.12312&lon=-12.91230&appid=apiKey&units=metric")
    }

	func testNilArrayItem() throws {
		let numbers: [Int]? = [1, 61, 34, 89]
		let url = try URLBuilder.buildThrowing {
			Host("panhans.dev")
			QueryItem(name: "test", value: numbers)
		}

		XCTAssertEqual(url.absoluteString, "https://panhans.dev?test=1,61,34,89")
	}

	func testArrayNilItems() throws {
		let numbers: [Int?] = [1, 34, nil, 89, nil]
		let url = try URLBuilder.buildThrowing {
			Host("panhans.dev")
			QueryItem(name: "test", value: numbers)
		}

		XCTAssertEqual(url.absoluteString, "https://panhans.dev?test=1,34,89")
	}

	func testNilArrayNilItems() throws {
		let numbers: [Int?]? = [9, 34, nil, 56, nil]
		let url = try URLBuilder.buildThrowing {
			Host("panhans.dev")
			QueryItem(name: "test", value: numbers)
		}

		XCTAssertEqual(url.absoluteString, "https://panhans.dev?test=9,34,56")
	}

	func testURLEncoding() throws {
		let url = try URLBuilder.buildThrowing {
			Host("panhans.dev")
			QueryItem(name: "test", value: "some string with spaces")
		}

		XCTAssertEqual(url.absoluteString, "https://panhans.dev?test=some%20string%20with%20spaces")
	}

	func testBuildBasicURL() throws {
		let url = try URL.buildThrowing {
			Scheme("https")
			Host("apple.com")
			Path("/products/iphone")
			PathComponent("old")
		}

		XCTAssertEqual(url.absoluteString, "https://apple.com/products/iphone/old")
	}

}
