import Foundation

public class NetworkResponse {

    public let data: Data
    public let httpResponse: HTTPURLResponse

    public init(data: Data, httpResponse: HTTPURLResponse) {
        self.data = data
        self.httpResponse = httpResponse
    }

}
