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

	// MARK: - Requests

	@discardableResult
	public func schedule<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping T.Completion) -> NetworkTask {
		let operation = NetworkOperation(request: request, progressHandler: progressHandler)
		operation.networkCompletionBlock = completion
		operationQueue.addOperation(operation)
		return operation.networkTask
    }

	public func scheduleSynchronously<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil) -> T.RequestResult {
		var result: T.RequestResult?
		let semaphore = RunLoopSemaphore(queue: request.finishingQueue)

		schedule(request: request, progressHandler: progressHandler) { requestResult in
			result = requestResult
			semaphore.signal()
		}

		let dispatchTime = DispatchTime.now() + request.urlSession.configuration.timeoutIntervalForRequest
		semaphore.wait(timeout: dispatchTime)

		return result ?? .failure(NSError.unknown)
	}

}
