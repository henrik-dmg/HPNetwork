#if canImport(Combine)
import Combine
import Foundation

extension DataRequest {

    public func dataTaskPublisher(urlSession: URLSession = .shared) -> AnyPublisher<Output, Error> {
        do {
            let request = try makeRequest()
            return dataTaskPublisher(with: request, urlSession: urlSession)
        } catch {
            return Future<Output, Error> { completion in
                completion(.failure(error))
            }.eraseToAnyPublisher()
        }
    }

    private func dataTaskPublisher(with request: URLRequest, urlSession: URLSession) -> AnyPublisher<Output, Error> {
        urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = (response as? HTTPURLResponse)?.httpResponse else {
                    throw NetworkRequestConversionError.failedToConvertURLResponseToHTTPResponse
                }
                try validateResponse(httpResponse)
                return (data, httpResponse)
            }
            .tryMap(convertResponse)
            .eraseToAnyPublisher()
    }

}
#endif
