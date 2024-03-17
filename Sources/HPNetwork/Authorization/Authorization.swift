import Foundation

/// A type that specifies authorization for a network request.
public protocol Authorization {

    /// The value that the `Authorization` header-field will be set to.
    var headerString: String { get }

}
