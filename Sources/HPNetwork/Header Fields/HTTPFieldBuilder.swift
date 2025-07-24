import Foundation
import HTTPTypes

@resultBuilder
public enum HTTPFieldBuilder {

    // MARK: - Expression

    public static func buildExpression(_ expression: HTTPField) -> [HTTPField] {
        [expression]
    }

    public static func buildExpression(_ expression: HTTPField?) -> [HTTPField] {
        expression.flatMap { [$0] } ?? []
    }

    public static func buildExpression(_ expression: [HTTPField]) -> [HTTPField] {
        expression
    }

    // MARK: - Optional

    public static func buildOptional(_ component: [HTTPField]?) -> [HTTPField] {
        component ?? []
    }

    // MARK: - Limited Availability

    public static func buildLimitedAvailability(_ component: [HTTPField]) -> [HTTPField] {
        component
    }

    // MARK: - Branching

    public static func buildEither(first components: [HTTPField]) -> [HTTPField] {
        components
    }

    public static func buildEither(second components: [HTTPField]) -> [HTTPField] {
        components
    }

    // MARK: - Partial

    public static func buildPartialBlock(first components: [HTTPField]) -> [HTTPField] {
        components
    }

    public static func buildPartialBlock(accumulated: [HTTPField], next: [HTTPField]) -> [HTTPField] {
        accumulated + next
    }

}
