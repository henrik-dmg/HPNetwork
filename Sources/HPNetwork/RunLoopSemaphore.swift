import Foundation

protocol SemaphoreProtocol {

	@discardableResult
	func wait(timeout: DispatchTime) -> DispatchTimeoutResult

	@discardableResult
	func signal() -> Int

}

extension DispatchSemaphore: SemaphoreProtocol {}

class RunLoopSemaphore: SemaphoreProtocol {

	private var isRunLoopNested = false
	private var isOperationCompleted = false

	@discardableResult
	func signal() -> Int {
		guard !isOperationCompleted else {
			return 0
		}
		isOperationCompleted = true

		if isRunLoopNested {
			CFRunLoopStop(CFRunLoopGetCurrent())
		}
		return 1
	}

	func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
		DispatchQueue.main.asyncAfter(deadline: timeout) { [weak self] in
			self?.signal()
		}
		if !isOperationCompleted {
			isRunLoopNested = true
			CFRunLoopRun()
			isRunLoopNested = false
		}

		return .success
	}

}

