import Foundation

public class Network {

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

}
