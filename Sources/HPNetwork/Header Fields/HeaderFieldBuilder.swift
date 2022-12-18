import Foundation

@resultBuilder
public enum HeaderFieldBuilder {

    public static func buildBlock(_ components: [HeaderField]...) -> [HeaderField] {
        components.flatMap { $0 }
    }

    /// Add support for both single and collections of constraints.
    public static func buildExpression(_ expression: HeaderField) -> [HeaderField] {
        [expression]
    }

    public static func buildExpression(_ expression: [HeaderField]) -> [HeaderField] {
        expression
    }

    /// Add support for optionals.
    public static func buildOptional(_ components: [HeaderField]?) -> [HeaderField] {
        components ?? []
    }

    /// Add support for if statements.
    public static func buildEither(first components: [HeaderField]) -> [HeaderField] {
        components
    }

    public static func buildEither(second components: [HeaderField]) -> [HeaderField] {
        components
    }

    public static func buildArray(_ components: [[HeaderField]]) -> [HeaderField] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [HeaderField]) -> [HeaderField] {
        component
    }

}
