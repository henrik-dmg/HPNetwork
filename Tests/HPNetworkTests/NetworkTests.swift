@testable import HPNetwork
import XCTest

class NetworkTests: XCTestCase {

    func testSimpleRequest() {
        let expectation = XCTestExpectation(description: "fetched from server")

        let request = DecodableRequest<EmptyStruct>(urlString: "https://ipapi.co/json")

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)
    }

    #if canImport(UIKit)
    func testImageDownload() {
        let avatarURLString = "https://avatars1.githubusercontent.com/u/9870054?s=460&u=e61c5240327e9bfdb20cae7fa0570e519db6033b&v=4"
        let url = URL(string: avatarURLString)
        let request = ImageDownloadRequest(url: url)

        let expectation = XCTestExpectation(description: "fetched from server")

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case .success(let image):
                print(image)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 20)
    }
    #endif

    #if canImport(AppKit)
    func testImageDownload() {
        let avatarURLString = "https://avatars1.githubusercontent.com/u/9870054?s=460&u=e61c5240327e9bfdb20cae7fa0570e519db6033b&v=4"
        let url = URL(string: avatarURLString)
        let request = ImageDownloadRequest(url: url)

        let expectation = XCTestExpectation(description: "fetched from server")

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case .success(let image):
                print(image)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 20)
    }
    #endif

    func testImageDownloadOnGlobal() {
        let expectation = XCTestExpectation(description: "fetched from server")

        let request = DecodableRequest<EmptyStruct>(urlString: "https://ipapi.co/json", finishingQueue: .global())

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
            XCTAssertFalse(Thread.isMainThread)
            switch result {
            case .success(let empty):
                print(empty)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 20)
    }

}

struct EmptyStruct: Codable {}
