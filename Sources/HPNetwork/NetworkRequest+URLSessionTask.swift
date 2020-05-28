import Foundation

extension NetworkRequest {

    internal func makeDataTask(completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError(description: "Failed to create URLRequest")))
            return nil
        }

        return URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            self.finish(data: data, response: response, error: error, completion: completion)
        }
    }

    internal func makeUploadTask(data: Data?, completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError(description: "Failed to create URLRequest")))
            return nil
        }

        return URLSession.shared.uploadTask(with: urlRequest, from: data) { data, response, error in
            self.finish(data: data, response: response, error: error, completion: completion)
        }
    }

    internal func makeUploadTask(fileURL: URL, completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask? {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError(description: "Failed to create URLRequest")))
            return nil
        }

        return URLSession.shared.uploadTask(with: urlRequest, fromFile: fileURL) { data, response, error in
            self.finish(data: data, response: response, error: error, completion: completion)
        }
    }

}
