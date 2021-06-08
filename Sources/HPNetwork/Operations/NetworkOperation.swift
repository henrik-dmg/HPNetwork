import Foundation
#if canImport(UIKit)
import UIKit
#endif

public typealias ProgressHandler = (Progress) -> Void

class NetworkOperation<R: NetworkRequest>: Operation {

	let request: R
	let progressHandler: ProgressHandler?
	var networkCompletionBlockWithElapsedTime: R.CompletionWithElapsedTime?
	let networkTask = NetworkTask()
	var startTime: DispatchTime?
	var networkingEndTime: DispatchTime?
	var processingEndTime: DispatchTime?

	var response: URLResponse?
	var error: Error?

	init(request: R, progressHandler: ProgressHandler?) {
		self.request = request
		self.progressHandler = progressHandler
	}

	override func main() {
		super.main()

		executeNetworkRequest()
		networkingEndTime = DispatchTime.now()
		let result = makeResult()
		processingEndTime = DispatchTime.now()
		finish(with: result)
	}

	override func cancel() {
		super.cancel()

		networkTask.cancel()

		if let error = error {
			finish(with: .failure(error))
		} else {
			finish(with: .failure(NSError.cancelledNetworkOperation))
		}
	}

	func makeResult() -> R.RequestResult {
		fatalError("Implement in subclass")
	}

	func executeNetworkRequest() {
		do {
			let urlRequest = try request.makeURLRequest()
			executeNetworkRequest(with: urlRequest)
		} catch let error {
			self.error = error
		}
	}

	func executeNetworkRequest(with urlRequest: URLRequest) {
		fatalError("Should be overridden in superclass")
	}

	func finish(with result: R.RequestResult) {
		request.finishingQueue.sync {
			let elapsedTime = calculateElapsedTime() ?? (-1, -1)
			networkCompletionBlockWithElapsedTime?(result, elapsedTime.0, elapsedTime.1)
			networkCompletionBlockWithElapsedTime = nil
		}
	}

	private func calculateElapsedTime() -> (TimeInterval, TimeInterval)? {
		guard
			let startTime = startTime,
			let networkingEndTime = networkingEndTime,
			let processingEndTime = processingEndTime
		else {
			return nil
		}

		let networkingTime = Double(networkingEndTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
		let processingTime = Double(processingEndTime.uptimeNanoseconds - networkingEndTime.uptimeNanoseconds)

		// converting nanoseconds to seconds
		return (networkingTime / 1e9, processingTime / 1e9)
	}

}
