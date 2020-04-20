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
        print(url?.absoluteString)

        XCTAssertEqual(url?.absoluteString, "https://api.openweathermap.org/data/2.5/onecall?lat=48.12312&lon=-12.91230&appid=apiKey&units=metric")
    }

    func testDownload() {
        let url = URL(string: "https://speed.hetzner.de/100MB.bin")

        let exp = XCTestExpectation(description: "Downloaded file")

        let request = DownloadRequest(url: url, authentication: nil)
        let task = Network.shared.downloadTask(request) { result in
            exp.fulfill()
            switch result {
            case .success(let file):
                print(file.absoluteString)
            case .failure(let error):
                print(error.localizedDescription)
                XCTFail()
            }
        }

        task.delegate = self
        print(task.delegate)

        wait(for: [exp], timeout: 60)
    }

}

extension URLQueryItemBuilderTests: DownloadTaskDelegate {

    func downloadProgressUpdate(_ session: URLSession, downloadTask: URLSessionDownloadTask, progress: Double) {
        print(progress)
    }

}
