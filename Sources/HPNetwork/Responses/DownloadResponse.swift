import Foundation

public struct DownloadResponse {

	public let url: URL
	public let urlResponse: URLResponse

	public init(url: URL, urlResponse: URLResponse) {
		self.url = url
		self.urlResponse = urlResponse
	}

}
