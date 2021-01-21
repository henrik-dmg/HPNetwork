#if canImport(Combine)
import Foundation
import Combine

public extension NetworkRequest {

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	func dataTaskPublisher() -> AnyPublisher<Output, Error> {
		if let request = urlRequest() {
			return urlSession.dataTaskPublisher(for: request)
				.receive(on: finishingQueue)
				.tryMap { data, response in
					if let error = response.urlError() {
						let convertedError = convertError(error, data: data, response: response)
						throw convertedError
					}
					return NetworkResponse(data: data, urlResponse: response)
				}
				.tryMap(convertResponse)
				.eraseToAnyPublisher()
		} else {
			return Future<Output, Error> { completion in
				completion(.failure(NSError.failedToCreateRequest))
			}.eraseToAnyPublisher()
		}
	}

}
#endif
