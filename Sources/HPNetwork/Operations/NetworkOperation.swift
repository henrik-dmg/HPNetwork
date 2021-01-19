import Foundation
#if canImport(UIKit)
import UIKit
#endif

public typealias ProgressHandler = (Progress) -> Void

class NetworkOperation<R: NetworkRequest>: Operation {

	let request: R
	let progressHandler: ProgressHandler?
	var networkCompletionBlock: R.Completion?
	let networkTask = NetworkTask()

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
		let result = request.dataTaskResult(data: data, response: response, error: error)
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

	func executeNetworkRequest() {
		guard let urlRequest = request.urlRequest() else {
			return
		}

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
		task.resume()
		semaphore.wait()
		observation?.invalidate()

		#if os(iOS) || os(tvOS)
		UIApplication.shared.endBackgroundTask(backgroundTask)
		#endif
	}

	private func finish(with result: R.RequestResult) {
		request.finishingQueue.sync {
			networkCompletionBlock?(result)
			networkCompletionBlock = nil
		}
	}

}
