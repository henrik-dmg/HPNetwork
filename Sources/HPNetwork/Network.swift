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
	public func schedule<T: NetworkRequest>(request: T, progressHandler: ProgressHandler? = nil, completion: @escaping (Result<T.Output, Error>) -> Void) -> NetworkTask {
		let operation = NetworkOperation(request: request, progressHandler: progressHandler)
		operation.networkCompletionBlock = completion
		operationQueue.addOperation(operation)
		return operation.networkTask
    }

}

extension URLResponse {

	func urlError() -> URLError? {
		guard let httpResponse = self as? HTTPURLResponse else {
			return nil
		}

		switch httpResponse.statusCode {
		case 200...299:
			return nil
		default:
			let errorCode = URLError.Code(rawValue: httpResponse.statusCode)
			return URLError(errorCode)
		}
	}

}
