# HPNetwork

![Swift](https://github.com/henrik-dmg/HPNetwork/workflows/Swift/badge.svg) [![codecov](https://codecov.io/gh/henrik-dmg/HPNetwork/graph/badge.svg?token=WZU3LZK4VD)](https://codecov.io/gh/henrik-dmg/HPNetwork)

`HPNetwork` is a protocol-based networking stack written in pure Swift

## Installation

Starting with v4 HPNetwork is only available via Swift Package Manager.

Add a new dependency for `https://github.com/henrik-dmg/HPNetwork` to your Xcode project or `.package(url: "https://github.com/henrik-dmg/HPNetwork", from: "4.0.0")` to your `Package.swift`

## Scheduling Requests

Scheduling a request is as easy as this:

```swift
let response = try await request.response()
```

The `response` is a `NetworkResponse<Output>` containing the output and statisticsof the request.

You can also get an async result:

```swift
let result = await request.result() // Result<NetworkResponse<Output>, Error>
```

Or schedule requests callback-based:

```swift
let task = request.schedule { result in
    switch result {
    case .success(let response):
        // handle response
    case .failure(let error):
        // handle error
    }
}
```

You can also use pretty much the same API with `NetworkClient` (useful for being able to mock requests in tests).

## Creating Requests

### Basics

HPNetwork is following a rather protocol based approach, so any type that conforms to `NetworkRequest` can be scheduled as a request. In the most simple terms, that means you supply a `URL` and a request method.

#### Example 1:

```swift
struct BasicDataRequest: DataRequest {

    typealias Output = Data

    var requestMethod: HTTPRequest.Method {
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
    let requestMethod: HTTPRequest.Method

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

    let requestMethod: HTTPRequest.Method

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

### Request Authorization

To add authorization to a request, simply supply a `authorization: Authorization?` instance to your request.
You can either use `BasicAuthorization` for basic authentication with a username and password, or `BearerAuthorization` for bearer token authorization or implement you own custom `Authorization` type.

## Mocking

There's a new `NetworkClientProtocol` type that you can schedule network requests on. To mock network requests, you can use `NetworkClientMock` from the new `HPNetworkMock` library.

Example usage:

```swift
networkClient.mockRequest(ofType: SomeRequest.self) { _ in
    ReturnTypeOfRequest() // or throw an error
}

// To remove all mocks

networkClient.removeAllMocks()
```

You can also specify whether `NetworkClientMock` should just fall-back to regular networking if there are no mocks configured for the request it's about the execute by using `fallbackToURLSessionIfNoMatchingMock`

If you need to go deeper, for example if you don't want to migrate to `NetworkClient`, you can use `URLSessionMock` to use with `URLSession`

Example usage of `URLSessionMock`:

```swift
lazy var mockedURLSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLSessionMock.self]
    return URLSession(configuration: configuration)
}()

// ...

_ = URLSessionMock.mockRequest(to: url, ignoresQuery: false) { _ in
    let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: ["Content-Type": ContentType.applicationJSON.rawValue]
    )!
    return (someDataYouWant, response)
}
```

## Authors

-   Henrik Panhans ([@henrik_dmg](https://twitter.com/henrik_dmg))
