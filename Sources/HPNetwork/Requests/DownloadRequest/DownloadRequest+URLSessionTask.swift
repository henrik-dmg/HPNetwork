import Foundation

// MARK: - Constructing Tasks

extension DownloadRequest {

	func makeDownloadTask(
		backgroundTask: BackgroundTaskWrapper,
		completion: @escaping (Result<URL, Error>) -> Void
	) -> URLSessionDownloadTask? {
		guard let urlRequest = makeURLRequest(completion: completion) else {
			return nil
		}

		let queue = finishingQueue

		return urlSession.downloadTask(with: urlRequest) { url, response, error in
			self.finishDownloadTask(
				url: url,
				response: response,
				error: error,
				backgroundTask: backgroundTask,
				finishingQueue: queue,
				completion: completion
			)
		}
	}

}

// MARK: - Finishing

extension DownloadRequest {

	func finishDownloadTask(
		url: URL?,
		response: URLResponse?,
		error: Error?,
		backgroundTask: BackgroundTaskWrapper,
		finishingQueue: DispatchQueue,
		completion: @escaping (Result<URL, Error>) -> Void)
	{
		let result = downloadTaskResult(url: url, response: response, error: error)

		finishingQueue.async {
			completion(result)

			#if os(iOS)
			guard let id = backgroundTask.backgroundTaskID else {
				return
			}
			UIApplication.shared.endBackgroundTask(id)
			#endif
		}
	}

	func downloadTaskResult(url: URL?, response: URLResponse?, error: Error?) -> Result<URL, Error> {
		let result: Result<URL, Error>

		if let error = error {
			result = .failure(error)
		} else if let error = Network.error(from: response) {
			let convertedError = convertError(error, response: response)
			result = .failure(convertedError)
		} else if let url = url {
			result = .success(url)
		} else {
			result = .failure(NSError.unknown)
		}

		return result
	}

}
