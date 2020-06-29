import Foundation

extension NetworkRequest {

    internal func makeDataTask(
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask?
    {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError.failedToCreate))
            return nil
        }

        let queue = finishingQueue

        return urlSession.dataTask(with: urlRequest) { data, response, error in
            self.finish(
                data: data,
                response: response,
                error: error,
                backgroundTask: backgroundTask,
                finishingQueue: queue,
                completion: completion)
        }
    }

    internal func makeUploadTask(
        data: Data?,
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask?
    {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError.failedToCreate))
            return nil
        }

        let queue = finishingQueue

        return urlSession.uploadTask(with: urlRequest, from: data) { data, response, error in
            self.finish(
                data: data,
                response: response,
                error: error,
                backgroundTask: backgroundTask,
                finishingQueue: queue,
                completion: completion)
        }
    }

    internal func makeUploadTask(
        fileURL: URL,
        backgroundTask: BackgroundTaskWrapper,
        completion: @escaping (Result<Output, Error>) -> Void) -> URLSessionDataTask?
    {
        guard let urlRequest = urlRequest() else {
            completion(.failure(NSError.failedToCreate))
            return nil
        }

        let queue = finishingQueue

        return urlSession.uploadTask(with: urlRequest, fromFile: fileURL) { data, response, error in
            self.finish(
                data: data,
                response: response,
                error: error,
                backgroundTask: backgroundTask,
                finishingQueue: queue,
                completion: completion)
        }
    }

}
