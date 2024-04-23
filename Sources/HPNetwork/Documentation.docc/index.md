# ``HPNetwork``

A flexible, protocol-based networking stack written in Swift.

## Overview

``HPNetwork`` is a flexible and extensible approach to networking in Swift. Check out ``DataRequest`` or ``DecodableRequest`` to get started.

## Installation

Starting with v4 HPNetwork is only available via Swift Package Manager.

- Package.swift: `.package(url: "https://github.com/henrik-dmg/HPNetwork", from: "4.0.0")`
- Xcode: `https://github.com/henrik-dmg/HPNetwork`

## Scheduling Requests

Scheduling a request is as easy as this:

```swift
let response = try await request.response()
```

The `response` is a ``NetworkResponse`` containing the output and statisticsof the request.

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

You can also use pretty much the same API with ``NetworkClient`` (useful for being able to mock requests in tests).

## Creating Requests

### Basics

HPNetwork is following a protocol-based approach, so any type that conforms to `NetworkRequest` can be scheduled as a request.
In the most simple terms, that means you supply a `URL` and a request method.

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

To add authorization to a request, simply supply a ``Authorization`` instance to your request.
You can either use ``BasicAuthorization`` for basic authentication with a username and password, or ``BearerAuthorization`` for bearer token authorization or implement you own custom ``Authorization`` type.
