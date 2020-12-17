import Foundation

public class NetworkResponse {

    public let data: Data
    public let urlResponse: URLResponse

    public init(data: Data, urlResponse: URLResponse) {
        self.data = data
        self.urlResponse = urlResponse
    }

}
