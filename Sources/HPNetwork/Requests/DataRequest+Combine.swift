#if canImport(Combine)
import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension DataRequest {

	func dataTaskPublisher() -> AnyPublisher<Output, Error> {
		do {
			let request = try makeURLRequest()
			return dataTaskPublisher(with: request)
		} catch let error {
			return Future<Output, Error> { completion in
				completion(.failure(error))
			}.eraseToAnyPublisher()
		}
	}

	private func dataTaskPublisher(with request: URLRequest) -> AnyPublisher<Output, Error> {
		urlSession.dataTaskPublisher(for: request)
			.receive(on: finishingQueue)
			.tryMap { data, response in
				if let error = response.urlError() {
					let convertedError = convertError(error, data: data, response: response)
					throw convertedError
				}
				return DataResponse(data: data, urlResponse: response)
			}
			.tryMap(convertResponse)
			.eraseToAnyPublisher()
	}

}
#endif
