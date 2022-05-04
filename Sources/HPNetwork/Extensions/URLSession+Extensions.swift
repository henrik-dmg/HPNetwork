import Foundation

extension URLSession {

    // MARK: - DataRequest

    func hp_data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        #if os(iOS)
            if #available(iOS 15, *) {
                return try await data(for: request, delegate: delegate)
            }
        #elseif os(OSX)
            if #available(macOS 12, *) {
                return try await data(for: request, delegate: delegate)
            }
        #elseif os(tvOS)
            if #available(tvOS 15, *) {
                return try await data(for: request, delegate: delegate)
            }
        #elseif os(watchOS)
            if #available(watchOS 8, *) {
                return try await data(for: request, delegate: delegate)
            }
        #endif

        return try await hp_dataContinuation(for: request)
    }

    func hp_dataContinuation(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    // MARK: - DownloadRequest

    func hp_download(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (URL, URLResponse) {
        #if os(iOS)
            if #available(iOS 15, *) {
                return try await download(for: request, delegate: delegate)
            }
        #elseif os(OSX)
            if #available(macOS 12, *) {
                return try await download(for: request, delegate: delegate)
            }
        #elseif os(tvOS)
            if #available(tvOS 15, *) {
                return try await download(for: request, delegate: delegate)
            }
        #elseif os(watchOS)
            if #available(watchOS 8, *) {
                return try await download(for: request, delegate: delegate)
            }
        #endif

        return try await hp_downloadContinuation(for: request)
    }

    func hp_downloadContinuation(for request: URLRequest) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = downloadTask(with: request) { url, response, error in
                guard let url = url, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (url, response))
            }
            task.resume()
        }
    }

}
