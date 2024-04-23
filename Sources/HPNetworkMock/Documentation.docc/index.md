# ``HPNetworkMock``

An extension library for ``HPNetwork`` to make mocking easy

## Overview

``HPNetworkMock`` allows you to either mock ``NetworkClientProtocol`` or if you need to go even deeper it provides a custom `URLProtocol`
that you can use to create a mocked `URLSession`.

### NetworkClientMock

There's a new ``NetworkClientProtocol`` type that you can schedule network requests on.
To mock network requests, you can use ``NetworkClientMock`` from the new ``HPNetworkMock`` library.

Example usage:

```swift
networkClient.mockRequest(ofType: SomeRequest.self) { _ in
    ReturnTypeOfRequest() // or throw an error
}

// To remove all mocks

networkClient.removeAllMocks()
```

You can also specify whether `NetworkClientMock` should just fall-back to regular networking if there are no mocks configured for the request it's about the execute by using `fallbackToURLSessionIfNoMatchingMock`

### URLSessionMock

If you need to go deeper, for example if you don't want to migrate to ``NetworkClient``, you can use ``URLSessionMock`` to use with `URLSession`

Example usage of ``URLSessionMock``:

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
