import Foundation
#if canImport(UIKit)
import UIKit
#endif

class DataOperation<R: DataRequest>: NetworkOperation<R> {

	private var data: Data?

	override func makeResult() -> R.RequestResult {
		request.dataTaskResult(data: data, response: response, error: error)
	}

	override func executeNetworkRequest(with urlRequest: URLRequest) {
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

}
