@testable import HPNetwork
import XCTest

class URLQueryItemBuilderTests: XCTestCase {

    func testURL() {
        let url = URLQueryItemsBuilder("api.openweathermap.org")
            .addingPathComponent("data")
            .addingPathComponent("2.5")
            .addingPathComponent("onecall")
            .addingQueryItem(48.123123012, name: "lat", digits: 5)
            .addingQueryItem(-12.9123001299, name: "lon", digits: 5)
            .addingQueryItem("apiKey", name: "appid")
            .addingQueryItem("metric", name: "units")
            .build()

        XCTAssertEqual(url?.absoluteString, "https://api.openweathermap.org/data/2.5/onecall?lat=48.12312&lon=-12.91230&appid=apiKey&units=metric")
    }

}
