import Foundation

public struct NetworkResponse<T> {

	public let output: T
	public let networkingDuration: TimeInterval
	public let processingDuration: TimeInterval

}
