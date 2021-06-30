import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public protocol QueryStringConvertible {

	var queryItemRepresentation: String { get }

}

public extension LosslessStringConvertible {

	var queryItemRepresentation: String { description }

}

extension String: QueryStringConvertible {}
extension Bool: QueryStringConvertible {}
extension Int: QueryStringConvertible {}
extension Int64: QueryStringConvertible {}
extension Int32: QueryStringConvertible {}
extension Int16: QueryStringConvertible {}
extension Int8: QueryStringConvertible {}
extension UInt: QueryStringConvertible {}
extension UInt64: QueryStringConvertible {}
extension UInt32: QueryStringConvertible {}
extension UInt16: QueryStringConvertible {}
extension UInt8: QueryStringConvertible {}
extension Double: QueryStringConvertible {}
extension Float: QueryStringConvertible {}

extension CGFloat: QueryStringConvertible {

	public var queryItemRepresentation: String {
		native.queryItemRepresentation
	}

}

extension URL: QueryStringConvertible {

	public var queryItemRepresentation: String {
		absoluteString
	}

}
