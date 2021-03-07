import Foundation

class RunLoopSemaphore {

	private let queue: DispatchQueue
	private var isRunLoopNested = false
	private var isOperationCompleted = false

	init(queue: DispatchQueue) {
		self.queue = queue
	}

	func signal() {
		guard !isOperationCompleted else {
			return
		}
		isOperationCompleted = true

		if isRunLoopNested {
			CFRunLoopStop(CFRunLoopGetCurrent())
		}
	}

	func wait(timeout: DispatchTime? = nil) {
		if let timeout = timeout {
			queue.asyncAfter(deadline: timeout) { [weak self] in
				self?.signal()
			}
		}
		if !isOperationCompleted {
			isRunLoopNested = true
			CFRunLoopRun()
			isRunLoopNested = false
		}
	}

}

