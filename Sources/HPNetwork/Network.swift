import Foundation

public class Network {

	// MARK: - Nested Types

	public struct Response<T> {
		public let output: T
		public let networkingDuration: TimeInterval
		public let processingDuration: TimeInterval
	}

	// MARK: - Properties

    public static let shared = Network()
	private let dispatchQueue: DispatchQueue

	private lazy var operationQueue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 10
		queue.underlyingQueue = dispatchQueue
		return queue
	}()

	public var maximumConcurrentRequests: Int {
		get {
			operationQueue.maxConcurrentOperationCount
		}
		set {
			operationQueue.maxConcurrentOperationCount = newValue
		}
	}

	// MARK: - Init

	public init(queue: DispatchQueue) {
		self.dispatchQueue = queue
	}

	convenience init() {
		let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .utility, attributes: .concurrent)
		self.init(queue: queue)
	}

	// MARK: - Data Requests

	@discardableResult
	public func schedule<T: DataRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.Completion) -> NetworkTask {
		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { result, _, _ in
			completion(result)
		}
    }

	@discardableResult
	public func scheduleIncludingElapsedTime<T: DataRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.CompletionWithElapsedTime) -> NetworkTask {
		let operation = DataOperation(request: request, progressHandler: progressHandler)
		operation.networkCompletionBlockWithElapsedTime = completion
		operationQueue.addOperation(operation)
		return operation.networkTask
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	@discardableResult
	public func schedule<T: DataRequest>(request: T, delegate: URLSessionDataDelegate? = nil) async throws -> Response<T.Output> {
		let urlRequest = try request.makeURLRequest()
		do {
			let startTime = DispatchTime.now()
			let result = try await request.urlSession.data(for: urlRequest, delegate: delegate)
			let networkingEndTime = DispatchTime.now()
			let convertedResult = try request.convertResponse(response: DataResponse(data: result.0, urlResponse: result.1))
			let processingEndTime = DispatchTime.now()
			let elapsedTime = Network.calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
			return Response(output: convertedResult, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
		} catch let error {
			let convertedError = request.convertError(error, data: nil, response: nil)
			throw convertedError
		}
	}

	// MARK: - Download Requests

	@discardableResult
	public func schedule<T: DownloadRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.Completion) -> NetworkTask {
		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { result, _, _ in
			completion(result)
		}
	}

	@discardableResult
	public func scheduleIncludingElapsedTime<T: DownloadRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.CompletionWithElapsedTime) -> NetworkTask {
		let operation = DownloadOperation(request: request, progressHandler: progressHandler)
		operation.networkCompletionBlockWithElapsedTime = completion
		operationQueue.addOperation(operation)
		return operation.networkTask
	}

	@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
	public func schedule<T: DownloadRequest>(request: T, delegate: URLSessionDataDelegate? = nil) async throws -> Response<T.Output> {
		let urlRequest = try request.makeURLRequest()
		do {
			let startTime = DispatchTime.now()
			let result = try await request.urlSession.download(for: urlRequest, delegate: delegate)
			let networkingEndTime = DispatchTime.now()
			let convertedResult = try request.convertResponse(response: DownloadResponse(url: result.0, urlResponse: result.1))
			let processingEndTime = DispatchTime.now()
			let elapsedTime = Network.calculateElapsedTime(startTime: startTime, networkingEndTime: networkingEndTime, processingEndTime: processingEndTime)
			return Response(output: convertedResult, networkingDuration: elapsedTime.0, processingDuration: elapsedTime.1)
		} catch let error {
			let convertedError = request.convertError(error, url: nil, response: nil)
			throw convertedError
		}
	}

	// MARK: - Download Asynchronously

	public func scheduleSynchronously<T: DataRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResult {
		scheduleSynchronouslyInludingElapsedTime(request: request, progressHandler: progressHandler).0
	}

	public func scheduleSynchronouslyInludingElapsedTime<T: DataRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResultIncludingElapsedTime {
		var resultIncludingElapsedTime: T.RequestResultIncludingElapsedTime?
		let semaphore: SemaphoreProtocol = request.finishingQueue == .main ? RunLoopSemaphore() : DispatchSemaphore(value: 0)

		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { requestResult, networkingTime, processingTime in
			resultIncludingElapsedTime = (requestResult, networkingTime, processingTime)
			semaphore.signal()
		}

		let dispatchTime = DispatchTime.now() + request.urlSession.configuration.timeoutIntervalForRequest
		semaphore.wait(timeout: dispatchTime)

		return resultIncludingElapsedTime ?? (.failure(NSError.unknown), 0, 0)
	}

	// MARK: - Download Synchronously

	public func scheduleSynchronously<T: DownloadRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResult {
		scheduleSynchronouslyInludingElapsedTime(request: request, progressHandler: progressHandler).0
	}

	public func scheduleSynchronouslyInludingElapsedTime<T: DownloadRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResultIncludingElapsedTime {
		var resultIncludingElapsedTime: T.RequestResultIncludingElapsedTime?
		let semaphore: SemaphoreProtocol = request.finishingQueue == .main ? RunLoopSemaphore() : DispatchSemaphore(value: 0)

		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { requestResult, networkingTime, processingTime in
			resultIncludingElapsedTime = (requestResult, networkingTime, processingTime)
			semaphore.signal()
		}

		let dispatchTime = DispatchTime.now() + request.urlSession.configuration.timeoutIntervalForRequest
		semaphore.wait(timeout: dispatchTime)

		return resultIncludingElapsedTime ?? (.failure(NSError.unknown), 0, 0)
	}

	// MARK: - Helpers

	private static func calculateElapsedTime(startTime: DispatchTime, networkingEndTime: DispatchTime, processingEndTime: DispatchTime) -> (TimeInterval, TimeInterval) {
		let networkingTime = Double(networkingEndTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
		let processingTime = Double(processingEndTime.uptimeNanoseconds - networkingEndTime.uptimeNanoseconds)

		// converting nanoseconds to seconds
		return (networkingTime / 1e9, processingTime / 1e9)
	}

}
