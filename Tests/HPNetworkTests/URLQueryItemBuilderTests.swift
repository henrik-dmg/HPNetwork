@testable import HPNetwork
import XCTest

class URLQueryItemBuilderTests: XCTestCase {

    func testURL() {
        let url = URLBuilder(host: "api.openweathermap.org")
            .addingPathComponent("data")
            .addingPathComponent("2.5")
            .addingPathComponent("onecall")
            .addingQueryItem(48.123123012, digits: 5, name: "lat")
            .addingQueryItem(-12.9123001299, digits: 5, name: "lon")
            .addingQueryItem("apiKey", name: "appid")
            .addingQueryItem("metric", name: "units")
            .build()

        XCTAssertEqual(url?.absoluteString, "https://api.openweathermap.org/data/2.5/onecall?lat=48.12312&lon=-12.91230&appid=apiKey&units=metric")
    }

	func testNilArrayItem() {
		let numbers: [Int]? = [1, 61, 34, 89]
		let url = URLBuilder(host: "panhans.dev")
			.addingQueryItem(numbers, name: "test")
			.build()

		XCTAssertEqual(url?.absoluteString, "https://panhans.dev?test=1,61,34,89")
	}

	func testArrayNilItems() {
		let numbers: [Int?] = [1, 34, nil, 89, nil]
		let url = URLBuilder(host: "panhans.dev")
			.addingQueryItem(numbers, name: "test")
			.build()

		XCTAssertEqual(url?.absoluteString, "https://panhans.dev?test=1,34,89")
	}

	func testNilArrayNilItems() {
		let numbers: [Int?]? = [9, 34, nil, 56, nil]
		let url = URLBuilder(host: "panhans.dev")
			.addingQueryItem(numbers, name: "test")
			.build()

		XCTAssertEqual(url?.absoluteString, "https://panhans.dev?test=9,34,56")
	}

}
