import HTTPTypes
import XCTest

@testable import HPNetwork
@testable import HPNetworkMock

final class NetworkRequestTests: XCTestCase {

    let url = URL(string: "https://ipapi.co/json")!

    lazy var mockedURLSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [NetworkRequestMock.self]
        return URLSession(configuration: configuration)
    }()

    lazy var networkClient = NetworkClient(urlSession: mockedURLSession)

    override func tearDown() {
        NetworkRequestMock.removeAllMocks()
        super.tearDown()
    }

    func testSimpleRequest() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let response = try await networkClient.response(request, delegate: nil)
        XCTAssertEqual(response.output, EmptyStruct())
    }

    func testEmptyRequest() async throws {
        mockNetworkRequest(url: url, dataToReturn: nil)

        let request = BasicDataRequest(url: url)
        let response = try await networkClient.response(request)
        XCTAssertEqual(response.output, Data())
    }

    func testSimpleRequestCompletionHandler() async throws {
        mockNetworkRequest(url: url, dataToReturn: "{}".data(using: .utf8))

        let request = BasicDecodableRequest<EmptyStruct>(url: url)
        let expection = XCTestExpectation(description: "Networking finished")
        _ = networkClient.schedule(request) { result in
            expection.fulfill()
            switch result {
            case .success(let response):
                XCTAssertEqual(response.output, EmptyStruct())
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        await fulfillment(of: [expection], timeout: 10)
    }

    func testFaultyRequest() {
        let request = FaultyRequest()
        XCTAssertThrowsError(try request.makeURL())
    }

    private func mockNetworkRequest(url: URL, dataToReturn data: Data?) {
        let mockedRequest = MockedNetworkRequest(urlString: url.absoluteString, ignoresQuery: false) { _ in
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": ContentType.applicationJSON.rawValue]
            )!
            return (data ?? Data(), response)
        }
        NetworkRequestMock.register(mockedRequest)
    }

}

private struct FaultyRequest: DataRequest {

    typealias Output = Data

    let requestMethod: HTTPRequest.Method = .get

    func makeURL() throws -> URL {
        throw URLError.urlNil
    }

}

private struct EmptyStruct: Codable, Equatable {}
