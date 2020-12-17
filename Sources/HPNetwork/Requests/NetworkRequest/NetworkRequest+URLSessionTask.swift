import Foundation

// MARK: - Constructing Tasks

extension NetworkRequest {

	// MARK: - Data Task

    func makeDataTask(
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void
	) -> URLSessionDataTask? {
		guard let urlRequest = makeURLRequest(completion: completion) else {
			return nil
		}

        let queue = finishingQueue

        return urlSession.dataTask(with: urlRequest) { data, response, error in
            self.finishDataTask(
                data: data,
                response: response,
                error: error,
                backgroundTask: backgroundTask,
                finishingQueue: queue,
                completion: completion
            )
        }
    }

	// MARK: - Upload Task

    func makeUploadTask(
        data: Data?,
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void
	) -> URLSessionUploadTask? {
		guard let urlRequest = makeURLRequest(completion: completion) else {
			return nil
		}

        let queue = finishingQueue

        return urlSession.uploadTask(with: urlRequest, from: data) { data, response, error in
            self.finishDataTask(
                data: data,
                response: response,
                error: error,
                backgroundTask: backgroundTask,
                finishingQueue: queue,
                completion: completion
            )
        }
    }

    func makeUploadTask(
        fileURL: URL,
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void
	) -> URLSessionUploadTask? {
		guard let urlRequest = makeURLRequest(completion: completion) else {
			return nil
		}

		let queue = finishingQueue

        return urlSession.uploadTask(with: urlRequest, fromFile: fileURL) { data, response, error in
            self.finishDataTask(
                data: data,
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

#if os(iOS)
import UIKit
#endif

extension NetworkRequest {

	// MARK: - Data Tasks

	func finishDataTask(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		backgroundTask: BackgroundTaskWrapper,
		finishingQueue: DispatchQueue,
		completion: @escaping (Result<Output, Error>) -> Void)
	{
		let result = dataTaskResult(data: data, response: response, error: error)

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

	func dataTaskResult(data: Data?, response: URLResponse?, error: Error?) -> Result<Output, Error> {
		let result: Result<Output, Error>

		if let error = error {
			result = .failure(error)
		} else if let error = Network.error(from: response) {
			let convertedError = convertError(error, data: data, response: response)
			result = .failure(convertedError)
		} else if let data = data, let response = response {
			do {
				let response = NetworkResponse(data: data, urlResponse: response)
				let output = try convertResponse(response: response)
				result = .success(output)
			} catch let error {
				result = .failure(error)
			}
		} else {
			result = .failure(NSError.unknown)
		}

		return result
	}

}
