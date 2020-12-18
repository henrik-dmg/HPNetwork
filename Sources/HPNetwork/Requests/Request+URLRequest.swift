import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif

extension Request {

	// Make sure background task and completion are still properly called in case the reqeust fails to construct
	func makeURLRequest(backgroundTask: BackgroundTaskWrapper, completion: @escaping (Result<Output, Error>) -> Void) -> URLRequest? {
		if let urlRequest = urlRequest() {
			return urlRequest
		}

		finishingQueue.async {
			completion(.failure(NSError.failedToCreate))

			#if os(iOS) || os(tvOS)
			guard let id = backgroundTask.backgroundTaskID else {
				return
			}
			UIApplication.shared.endBackgroundTask(id)
			#endif
		}

		return nil
	}

}
