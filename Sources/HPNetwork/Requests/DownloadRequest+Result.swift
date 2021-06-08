import Foundation

extension DownloadRequest {

	func downloadTaskResult(url: URL?, response: URLResponse?, error: Error?) -> Result<Output, Error> {
		let result: Result<Output, Error>

		if let error = error {
			result = .failure(error)
		} else if let error = response?.urlError() {
			let convertedError = convertError(error, url: url, response: response)
			result = .failure(convertedError)
		} else if let url = url, let response = response {
			do {
				let response = DownloadResponse(url: url, urlResponse: response)
				let output = try convertResponse(response: response)
				result = .success(output)
			} catch let error {
				result = .failure(error)
			}
		} else {
			result = .failure(NSError.unknown)
		}

		return result
	}

}
