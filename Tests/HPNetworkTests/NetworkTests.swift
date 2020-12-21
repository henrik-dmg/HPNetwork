@testable import HPNetwork
import XCTest
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class NetworkTests: XCTestCase {

    func testSimpleRequest() {
        let expectation = XCTestExpectation(description: "fetched from server")

		let request = BasicDecodableRequest<Int>(url: URL(string: "https://ipapi.co/json"))

		Network.shared.schedule(request: request) { result in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)
    }

	func testConcurrentOperations() {
		let network = Network.shared

		let expectation = XCTestExpectation(description: "fetched request from server")
		expectation.expectedFulfillmentCount = 20

		for i in 0...20 {
			let request = BasicRequest(url: URL(string: "https://panhans.dev"))

			network.schedule(request: request) { result in
				print("finished request \(i)")
				expectation.fulfill()
			}
		}

		wait(for: [expectation], timeout: 20)
	}

	func testConcurrentOperationsMaxOne() {
		let network = Network.shared
		network.maximumConcurrentRequests = 1

		let expectation = XCTestExpectation(description: "fetched request from server")
		expectation.expectedFulfillmentCount = 20

		var finishedRequests = [Int]()

		for i in 0...20 {
			let request = BasicRequest(url: URL(string: "https://panhans.dev"))

			network.schedule(request: request) { result in
				finishedRequests.append(i)
				expectation.fulfill()
			}
		}

		wait(for: [expectation], timeout: 20)

		XCTAssertEqual(finishedRequests, Array(0...19))
	}

    #if canImport(UIKit)
    func testImageDownload() {
        let avatarURLString = "https://avatars1.githubusercontent.com/u/9870054?s=460&u=e61c5240327e9bfdb20cae7fa0570e519db6033b&v=4"
        let url = URL(string: avatarURLString)
		let request = BasicImageRequest(url: url, requestMethod: .get)

        let expectation = XCTestExpectation(description: "fetched from server")

		Network.shared.schedule(request: request) { result in
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case .success(let image):
				print(image.size)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
			expectation.fulfill()
        }

        wait(for: [expectation], timeout: 20)
    }
    #endif

    #if canImport(AppKit)
    func testImageDownload() {
        let avatarURLString = "https://avatars1.githubusercontent.com/u/9870054?s=460&u=e61c5240327e9bfdb20cae7fa0570e519db6033b&v=4"
        let url = URL(string: avatarURLString)
		let request = BasicImageRequest(url: url, requestMethod: .get)

        let expectation = XCTestExpectation(description: "fetched from server")

		Network.shared.schedule(request: request) { progress in
			print(progress.fractionCompleted)
		} completion: { result in
			XCTAssertTrue(Thread.isMainThread)
			switch result {
			case .success(let image):
				print(image)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			expectation.fulfill()
		}

        wait(for: [expectation], timeout: 20)
    }
    #endif

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	func testPublisher() {
		let expectationFinished = expectation(description: "finished")
		let expectationReceive = expectation(description: "receiveValue")

		let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))

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

#if canImport(UIKit)

import UIKit

struct BasicImageRequest: NetworkRequest {

	typealias Output = UIImage

	let url: URL?
	let requestMethod: NetworkRequestMethod

	func convertResponse(response: NetworkResponse) throws -> UIImage {
		guard let image = UIImage(data: response.data) else {
			throw NSError.imageError
		}
		return image
	}

}

#elseif canImport(AppKit)

import AppKit

struct BasicImageRequest: NetworkRequest {

	typealias Output = NSImage

	let url: URL?
	let requestMethod: NetworkRequestMethod

	func convertResponse(response: NetworkResponse) throws -> NSImage {
		guard let image = NSImage(data: response.data) else {
			throw NSError.imageError
		}
		return image
	}

}

#endif

struct BasicDecodableRequest<Output: Decodable>: DecodableRequest {

	let url: URL?
	let requestMethod: NetworkRequestMethod = .get

	var decoder: JSONDecoder {
		JSONDecoder()
	}

}

struct BasicRequest: NetworkRequest {

	typealias Output = Data
	let url: URL?
	let requestMethod: NetworkRequestMethod = .get

}

struct FaultyRequest: NetworkRequest {

	typealias Output = Data

	var requestMethod: NetworkRequestMethod {
		.get
	}

	var url: URL? {
		nil
	}

}

struct EmptyStruct: Codable {}
