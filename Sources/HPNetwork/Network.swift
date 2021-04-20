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
		let queue = DispatchQueue(label: "com.henrikpanhans.Network", qos: .userInitiated, attributes: .concurrent)
		self.init(queue: queue)
	}

	// MARK: - Asynchronous Requests

	@discardableResult
	public func schedule<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.Completion) -> NetworkTask {
		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { result, _, _ in
			completion(result)
		}
    }

	@discardableResult
	public func scheduleIncludingElapsedTime<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.CompletionWithElapsedTime) -> NetworkTask {
		let operation = NetworkOperation(request: request, progressHandler: progressHandler)
		operation.networkCompletionBlockWithElapsedTime = completion
		operationQueue.addOperation(operation)
		return operation.networkTask
	}

	// MARK: - Synchronous Requests

	public func scheduleSynchronously<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResult {
		scheduleSynchronouslyInludingElapsedTime(request: request, progressHandler: progressHandler).0
	}

	public func scheduleSynchronouslyInludingElapsedTime<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResultIncludingElapsedTime {
		var resultIncludingElapsedTime: T.RequestResultIncludingElapsedTime?
		let semaphore = RunLoopSemaphore(queue: request.finishingQueue)

		scheduleIncludingElapsedTime(request: request, progressHandler: progressHandler) { requestResult, networkingTime, processingTime in
			resultIncludingElapsedTime = (requestResult, networkingTime, processingTime)
			semaphore.signal()
		}

		let dispatchTime = DispatchTime.now() + request.urlSession.configuration.timeoutIntervalForRequest
		semaphore.wait(timeout: dispatchTime)

		return resultIncludingElapsedTime ?? (.failure(NSError.unknown), 0, 0)
	}

}
