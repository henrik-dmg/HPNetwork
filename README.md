# HPNetwork

![Swift](https://github.com/henrik-dmg/HPNetwork/workflows/Swift/badge.svg)

`HPNetwork` is a protocol-based networking stack written in pure Swift

## Installation

### SPM

Add a new dependency for `https://github.com/henrik-dmg/HPNetwork` to your Xcode project or `.package(url: "https://github.com/henrik-dmg/HPNetwork/tree/feature/async", from: "3.0.0")` to your `Package.swift`

### CocoaPods

Add `pod 'HPNetwork'` to your Podfile and run `pod install`

## Posting Request

Scheduling a request is as easy as this:

```swift
let response = try await request.response()
```

The `response` is a `NetworkResponse<Output>` containing the output and statisticsof the request.

### Combine

You can also call `dataTaskPublisher()` on any `NetworkRequest` instance to get a `AnyPublisher<Request.Output, Error`. The publisher will walk through the same validation and error handling process as the `response()` method.

### Synchronous Requests

If you do stuff like writing CLIs with Swift or need to do synchronous networking for any reason, you can use `scheduleSynchronously(...)` which returns the same `Result<NetworkRequest.Output, Error>` as in the closure of the regular method call. There's also a convenience method for `NetworkRequest` directly which you can call by `request.scheduleSynchronously(...)`

### Cancelling Requests

Any call to `schedule(request) { result in ... }` returns an instance of `NetworkTask` that you can cancel by calling `task.cancel()`

## Creating Requests

### Basics

HPNetwork is following a rather protocol based approach, so any type that conforms to `NetworkRequest` can be scheduled as a request. In the most simple terms, that means you supply a `URL` and a request method.

#### Example 1:

```swift
struct BasicDataRequest: DataRequest {

    typealias Output = Data

    var requestMethod: NetworkRequestMethod {
        .get
    }

    func makeURL() throws -> URL {
		// construct your URL here
	}

}
```

### Example 2:

```swift
struct BasicDataRequest: DataRequest {

    typealias Output = Data

    let url: URL?
    let requestMethod: NetworkRequestMethod

    func makeURL() throws -> URL {
		// construct your URL here
	}

}

let basicRequest = BasicDataRequest(
    url: URL(string: "https://panhans.dev/"),
    requestMethod: .get
)
```

### JSON

If you're working with JSON, you can also use `DecodableRequest` which requires a `JSONDecoder` to be supplied. The request will use that decoder to automatically convert the received data to the specified output type

#### Example 3:

```swift
struct BasicDecodableRequest<Output: Decodable>: DecodableRequest {

    let requestMethod: NetworkRequestMethod

    var decoder: JSONDecoder {
        JSONDecoder() // use default or custom decoder
    }

    func makeURL() throws -> URL {
		// construct your URL here
	}

}
```

### Intercepting Errors

By default, instances of `NetworkRequest` will simply forward any encountered errors to the completion block. If you want to do some custom error conversion based on the raw `Data` that was received, you can implement `func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error` in your request model.

### URLBuilder

`URLBuilder` has been broken out into a separate package `HPURLBuilder` that can be found [here](https://github.com/henrik-dmg/HPURLBuilder)

### Request Authentication

To add authentication to a request, simply supply a `authentication: NetworkRequestAuthentication?` instance to your request. `NetworkRequestAuthentication` is an enum and supports basic authentication with a username and password, bearer token authorisation or a raw option if you want full control.

### Everything else

Things like `httpBody: Data?` and `headerFields: [NetworkRequestHeaderField]` should be pretty self-explanatory so I'm gonna let you figure those out on your own.

## WIP

- [x] Cancellation support
- [x] Progress callback
- [x] Improving the documentation
- [x] Add `async` variants for the new Swift version
- [ ] Cookie support
````
