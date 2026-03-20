import Testing

@testable import HPNetwork

@Suite struct HTTPFieldBuilderTests {

    @Test func fieldBuiler_SimpleField() {
        let fields = buildHTTPFields {
            HTTPField.contentType(.applicationJSON)
        }
        #expect(fields == [HTTPField.contentType(.applicationJSON)])
    }

    @Test func fieldBuiler_Array() {
        let expectedFields = [HTTPField.contentType(.applicationJSON), HTTPField.contentType(.applicationJSON)]
        let fields = buildHTTPFields {
            expectedFields
        }
        #expect(fields == expectedFields)
    }

    @Test func fieldBuiler_Array_Alternative() {
        let expectedFields = [HTTPField.contentType(.applicationJSON), HTTPField.contentType(.applicationJSON)]
        let fields = buildHTTPFields {
            [HTTPField.contentType(.applicationJSON), HTTPField.contentType(.applicationJSON)]
        }
        #expect(fields == expectedFields)
    }

    @Test func fieldBuiler_LimitedAvailability() {
        let expectedFields = [HTTPField.contentType(.applicationJSON), HTTPField.contentType(.applicationJSON)]
        let fields = buildHTTPFields {
            if #available(iOS 18, *) {
                expectedFields
            }
        }
        #expect(fields == expectedFields)
    }

    @Test func fieldBuiler_Optional() {
        let expectedField: HTTPField? = HTTPField.contentType(.applicationJSON)
        let fields = buildHTTPFields {
            expectedField
        }
        #expect(fields == [expectedField])
    }

    @Test func fieldBuiler_IfBranchFirst() {
        let expectedField = HTTPField.contentType(.applicationJSON)
        let branch = true
        let fields = buildHTTPFields {
            if branch {
                expectedField
            } else {
                expectedField
            }
        }
        #expect(fields == [expectedField])
    }

    @Test func fieldBuiler_IfBranchSecond() {
        let expectedField = HTTPField.contentType(.applicationJSON)
        let branch = false
        let fields = buildHTTPFields {
            if branch {
                expectedField
            } else {
                expectedField
            }
        }
        #expect(fields == [expectedField])
    }

    private func buildHTTPFields(@HTTPFieldBuilder fields: () -> [HTTPField]) -> [HTTPField] {
        fields()
    }

}
