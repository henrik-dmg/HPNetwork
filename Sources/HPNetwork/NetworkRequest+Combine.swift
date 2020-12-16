#if canImport(Combine)
import Foundation
import Combine

public extension NetworkRequest {

	@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
	func dataTaskPublisher() -> AnyPublisher<Output, Error> {
		guard let request = urlRequest() else {
			return NetworkRequestErrorPublisher<Output>(error: NSError.failedToCreate).eraseToAnyPublisher()
		}

		return urlSession.dataTaskPublisher(for: request)
			.receive(on: finishingQueue)
			.tryMap { data, response in
				if let error = Network.error(from: response) {
					let convertedError = convertError(error, data: data, response: response)
					throw convertedError
				}
				guard let urlResponse = response as? HTTPURLResponse else {
					throw NSError.unknown
				}
				return NetworkResponse(data: data, httpResponse: urlResponse)
			}
			.tryMap(convertResponse)
			.eraseToAnyPublisher()
	}

}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct NetworkRequestErrorPublisher<Output>: Publisher {

	typealias Failure = Error

	let error: Failure

	func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
		subscriber.receive(completion: .failure(error))
	}

}
#endif
