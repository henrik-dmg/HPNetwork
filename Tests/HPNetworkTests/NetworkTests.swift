@testable import HPNetwork
import XCTest
import Combine

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

		let customQueue = DispatchQueue(label: "com.henrikpanhans.HPNetworkTests")
		let request = DecodableRequest<EmptyStruct>(urlString: "https://ipapi.co/json", finishingQueue: customQueue)

        Network.shared.dataTask(request) { result in
            expectation.fulfill()
			XCTAssertEqual(OperationQueue.main.underlyingQueue, customQueue)
            switch result {
            case .success(let empty):
                print(empty)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 20)
    }

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	func testPublisher() {
		let expectationFinished = expectation(description: "finished")
		let expectationReceive = expectation(description: "receiveValue")

		let request = DecodableRequest<EmptyStruct>(urlString: "https://ipapi.co/json")

		let cancellable = request.dataTaskPublisher().sink { result in
			switch result {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .finished:
				expectationFinished.fulfill()
			}
		} receiveValue: { response in
			expectationReceive.fulfill()
		}

		waitForExpectations(timeout: 10) { error in
			cancellable.cancel()
		}
	}

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	func testPublisherFailure() {
		let expectationFinished = expectation(description: "finished")

		let request = FaultyRequest()

		let cancellable = request.dataTaskPublisher().sink { result in
			switch result {
			case .failure(let error as NSError):
				XCTAssertEqual(error, NSError.failedToCreate)
				expectationFinished.fulfill()
			case .finished:
				XCTFail("Networking should not be successful")
			}
		} receiveValue: { response in
			//
		}

		waitForExpectations(timeout: 10) { error in
			cancellable.cancel()
		}
	}

}

struct FaultyRequest: NetworkRequest {

	var requestMethod: NetworkRequestMethod {
		.get
	}

	var url: URL? {
		nil
	}

}

struct EmptyStruct: Codable {}
