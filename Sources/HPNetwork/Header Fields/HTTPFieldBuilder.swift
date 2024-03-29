import Foundation
import HTTPTypes

@resultBuilder
public enum HTTPFieldBuilder {

    public static func buildBlock(_ components: [HTTPField]...) -> [HTTPField] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [HTTPField]?) -> [HTTPField] {
        component ?? []
    }

    public static func buildOptional(_ component: [HTTPField?]?) -> [HTTPField] {
        component?.compactMap { $0 } ?? []
    }

    /// Add support for both single and collections of constraints.
    public static func buildExpression(_ expression: HTTPField) -> [HTTPField] {
        [expression]
    }

    public static func buildExpression(_ expression: [HTTPField]) -> [HTTPField] {
        expression
    }

    /// Add support for if statements.
    public static func buildEither(first components: [HTTPField]) -> [HTTPField] {
        components
    }

    public static func buildEither(second components: [HTTPField]) -> [HTTPField] {
        components
    }

    public static func buildArray(_ components: [[HTTPField]]) -> [HTTPField] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [HTTPField]) -> [HTTPField] {
        component
    }

}
