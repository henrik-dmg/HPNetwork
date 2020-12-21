import Foundation

extension NetworkRequest {

	func dataTaskResult(data: Data?, response: URLResponse?, error: Error?) -> Result<Output, Error> {
		let result: Result<Output, Error>

		if let error = error {
			result = .failure(error)
		} else if let error = response?.urlError() {
			let convertedError = convertError(error, data: data, response: response)
			result = .failure(convertedError)
		} else if let data = data, let response = response {
			do {
				let response = NetworkResponse(data: data, urlResponse: response)
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
