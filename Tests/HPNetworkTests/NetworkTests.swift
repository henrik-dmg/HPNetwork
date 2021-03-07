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
		let expectation = XCTestExpectation(description: "fetched request from server")
		expectation.expectedFulfillmentCount = 20

		for _ in 0...20 {
			let request = BasicRequest(url: URL(string: "https://panhans.dev"))

			request.schedule { _ in
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

	func testLargeFileDownload() {
		let network = Network.shared

		let expectation = XCTestExpectation(description: "fetched request from server")

		let request = BasicRequest(url: URL(string: "https://panhans.dev/resources/random_data_10_mb"))

		network.schedule(request: request) { result in
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 40)
	}

    #if canImport(UIKit)
    func testImageDownload() {
        let avatarURLString = "https://panhans.dev/resources/Ugly-Separators.png"
        let url = URL(string: avatarURLString)
		let request = BasicImageRequest(url: url, requestMethod: .get)

        let expectation = XCTestExpectation(description: "fetched from server")

		Network.shared.schedule(request: request) { result in
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case .success:
				break
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
        let avatarURLString = "https://panhans.dev/resources/Ugly-Separators.png"
        let url = URL(string: avatarURLString)
		let request = BasicImageRequest(url: url, requestMethod: .get)

        let expectation = XCTestExpectation(description: "fetched from server")

		Network.shared.schedule(request: request) { progress in
			print(progress.fractionCompleted)
		} completion: { result in
			XCTAssertTrue(Thread.isMainThread)
			switch result {
			case .success:
				break
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
				XCTAssertEqual(error, NSError.failedToCreateRequest.withFailureReason("The URL instance to create the request is nil"))
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

	func testCancellingRequest() {
		let expectation = XCTestExpectation(description: "fetched from server")

		let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))

		let task = Network.shared.schedule(request: request) { result in
			switch result {
			case .success:
				XCTFail()
			case .failure(let error as NSError):
				print(error)
			}
			expectation.fulfill()
		}
		task.cancel()

		wait(for: [expectation], timeout: 20)
	}

	func testSync() {
		let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))
		let result = Network.shared.scheduleSynchronously(request: request)
		switch result {
		case .success:
			break
		case .failure(let error):
			XCTFail(error.localizedDescription)
		}
	}

	func testSync2() {
		let request = BasicDecodableRequest<EmptyStruct>(url: URL(string: "https://ipapi.co/json"))
		let result = request.scheduleSynchronously(on: .shared)
		switch result {
		case .success:
			break
		case .failure(let error):
			XCTFail(error.localizedDescription)
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
