# HPNetwork

![Swift](https://github.com/henrik-dmg/HPNetwork/workflows/Swift/badge.svg) [![codecov](https://codecov.io/gh/henrik-dmg/HPNetwork/graph/badge.svg?token=WZU3LZK4VD)](https://codecov.io/gh/henrik-dmg/HPNetwork)

`HPNetwork` is a protocol-based networking stack written in pure Swift

## Installation

### SPM

Add a new dependency for `https://github.com/henrik-dmg/HPNetwork` to your Xcode project or `.package(url: "https://github.com/henrik-dmg/HPNetwork", from: "4.0.0")` to your `Package.swift`

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

### URLBuilder

`URLBuilder` has been broken out into a separate package `HPURLBuilder` that can be found [here](https://github.com/henrik-dmg/HPURLBuilder)

### Request Authentication

To add authentication to a request, simply supply a `authentication: NetworkRequestAuthentication?` instance to your request. `NetworkRequestAuthentication` is an enum and supports basic authentication with a username and password, bearer token authorisation or a raw option if you want full control.

### Authors

- Henrik Panhans ([@henrik_dmg](https://twitter.com/henrik_dmg))
