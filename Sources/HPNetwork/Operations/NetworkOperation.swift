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

	private var data: Data?
	private var response: URLResponse?
	private var error: Error?

	init(request: R, progressHandler: ProgressHandler?) {
		self.request = request
		self.progressHandler = progressHandler
	}

	override func main() {
		super.main()

		executeNetworkRequest()
		networkingEndTime = DispatchTime.now()
		let result = request.dataTaskResult(data: data, response: response, error: error)
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

	private func executeNetworkRequest() {
		do {
			let urlRequest = try request.makeURLRequest()
			executeNetworkRequest(with: urlRequest)
		} catch let error {
			self.error = error
		}
	}

	private func executeNetworkRequest(with urlRequest: URLRequest) {
		#if os(iOS) || os(tvOS)
		let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
		#endif

		let semaphore = DispatchSemaphore(value: 0)

		let task = request.urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
			self?.data = data
			self?.response = response
			self?.error = error
			semaphore.signal()
		}

		var observation: NSKeyValueObservation?
		if #available(iOS 11.0, tvOS 11.0, macOS 10.13, watchOS 4.0, *), let handler = progressHandler {
			let queue = request.finishingQueue
			observation = task.progress.observe(\.fractionCompleted) { progress, _ in
				queue.async {
					handler(progress)
				}
			}
		}

		networkTask.set(task)
		startTime = DispatchTime.now()
		task.resume()
		semaphore.wait()
		observation?.invalidate()

		#if os(iOS) || os(tvOS)
		UIApplication.shared.endBackgroundTask(backgroundTask)
		#endif
	}

	private func finish(with result: R.RequestResult) {
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
