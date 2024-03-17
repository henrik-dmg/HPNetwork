import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

final class HTTPFieldBuilderTests: XCTestCase {

    func testFieldBuiler_SimpleField() {
        let fields = buildHTTPFields {
            HTTPField.contentType(.applicationJSON)
        }
        XCTAssertEqual(fields, [HTTPField.contentType(.applicationJSON)])
    }

    func testFieldBuiler_Array() {
        let expectedFields = [HTTPField.contentType(.applicationJSON), HTTPField.contentType(.applicationJSON)]
        let fields = buildHTTPFields {
            expectedFields
        }
        XCTAssertEqual(fields, expectedFields)
    }

    func testFieldBuiler_Optional() {
        let expectedField: HTTPField? = HTTPField.contentType(.applicationJSON)
        let fields = buildHTTPFields {
            if let expectedField {
                expectedField
            }
        }
        XCTAssertEqual(fields, [expectedField])
    }

    func testFieldBuiler_IfBranchFirst() {
        let expectedField = HTTPField.contentType(.applicationJSON)
        let branch = true
        let fields = buildHTTPFields {
            if branch {
                expectedField
            } else {
                expectedField
            }
        }
        XCTAssertEqual(fields, [expectedField])
    }

    func testFieldBuiler_IfBranchSecond() {
        let expectedField = HTTPField.contentType(.applicationJSON)
        let branch = false
        let fields = buildHTTPFields {
            if branch {
                expectedField
            } else {
                expectedField
            }
        }
        XCTAssertEqual(fields, [expectedField])
    }

    private func buildHTTPFields(@HTTPFieldBuilder fields: () -> [HTTPField]) -> [HTTPField] {
        fields()
    }

}
