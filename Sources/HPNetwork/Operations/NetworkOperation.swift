import Foundation

public typealias ProgressHandler = (Progress) -> Void

class NetworkOperation<R: NetworkRequest>: Operation {

	typealias RequestResult = Result<R.Output, Error>
	typealias Completion = (Result<R.Output, Error>) -> Void

	let request: R
	let progressHandler: ProgressHandler?
	var networkCompletionBlock: Completion?

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
		let cancelledBeforeExecution = !isExecuting && !isFinished && !isCancelled
		super.cancel()

		// If we are cancelled before being started, then `main` and `networkOperationCompletionBlock` are never executed so we ensure
		// that a cancel error is delivered.
		if cancelledBeforeExecution {
			if let error = error {
				finish(with: .failure(error))
			} else {
				finish(with: .failure(NSError.cancelledNetworkOperation))
			}
		}
	}

	func executeNetworkRequest() {
		guard let urlRequest = request.urlRequest() else {
			return
		}

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

		task.resume()
		semaphore.wait()
		observation?.invalidate()
	}

	private func finish(with result: RequestResult) {
		request.finishingQueue.sync {
			networkCompletionBlock?(result)
			networkCompletionBlock = nil
		}
	}

}
