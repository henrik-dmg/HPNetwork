#if canImport(Combine)
import Foundation
import Combine

public extension DataRequest {

	func dataTaskPublisher() -> AnyPublisher<Output, Error> {
		do {
			let request = try urlRequest()
			return dataTaskPublisher(with: request)
		} catch let error {
			return Future<Output, Error> { completion in
				completion(.failure(error))
			}.eraseToAnyPublisher()
		}
	}

	private func dataTaskPublisher(with request: URLRequest) -> AnyPublisher<Output, Error> {
		urlSession.dataTaskPublisher(for: request)
			.tryMap { data, response in
				if let error = response.urlError() {
					let convertedError = convertError(error: error, data: data, response: response)
					throw convertedError
				}
				return (data, response)
			}
			.tryMap(convertResponse)
			.eraseToAnyPublisher()
	}

}
#endif
