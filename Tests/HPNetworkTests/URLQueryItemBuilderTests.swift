@testable import HPNetwork
import XCTest

class URLQueryItemBuilderTests: XCTestCase {

    func testURL() {
		measure {
			let url = URLBuilder.build {
				Host("api.openweathermap.org")
				PathComponent("data")
				PathComponent("2.5")
				PathComponent("onecall")
				QueryItem(name: "lat", value: 48.123123012, digits: 5)
				QueryItem(name: "lon", value: -12.9123001299, digits: 5)
				QueryItem(name: "appid", value: "apiKey")
				QueryItem(name: "units", value: "metric")
			}

			XCTAssertEqual(url?.absoluteString, "https://api.openweathermap.org/data/2.5/onecall?lat=48.12312&lon=-12.91230&appid=apiKey&units=metric")
		}
    }

	func testNilArrayItem() {
		measure {
			let numbers: [Int]? = [1, 61, 34, 89]
			let url = URLBuilder.build {
				Host("panhans.dev")
				QueryItem(name: "test", value: numbers)
			}

			XCTAssertEqual(url?.absoluteString, "https://panhans.dev?test=1,61,34,89")
		}
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

	func testComplexBuilder() throws {
		let token: String?  = "asdasads"
		let filters: [Filter]? = [Filter(name: "firstFilter", value: "name"), Filter(name: "secondFilter", value: "lastName")]

		measure {
			let url = URL.build {
				Host("apple.com")
				PathComponent("some/path")
				QueryItem(name: "print", value: "silent")

				ForEach(filters) { filter in
					QueryItem(name: filter.name, value: filter.value)
				}

				QueryItem(name: "auth", value: token)
			}

			XCTAssertEqual(url?.absoluteString, "https://apple.com/some/path?print=silent&firstFilter=name&secondFilter=lastName&auth=\(token!)")
		}
	}

}

private struct Filter {
	let name: String
	let value: String
}
