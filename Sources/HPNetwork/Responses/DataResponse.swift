import Foundation

public struct DataResponse {

    public let data: Data
    public let urlResponse: URLResponse

    public init(data: Data, urlResponse: URLResponse) {
        self.data = data
        self.urlResponse = urlResponse
    }

}
