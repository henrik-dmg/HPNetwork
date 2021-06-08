import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif

final class DownloadOperation<R: DownloadRequest>: NetworkOperation<R> {

	private var url: URL?

	override func makeResult() -> R.RequestResult {
		request.downloadTaskResult(url: url, response: response, error: error)
	}

	override func executeNetworkRequest(with urlRequest: URLRequest) {
		#if os(iOS) || os(tvOS)
		let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
		#endif

		let semaphore = DispatchSemaphore(value: 0)

		let task = request.urlSession.downloadTask(with: urlRequest) { fileURL, response, error in
			self.url = fileURL
			self.response = response
			self.error = error
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
