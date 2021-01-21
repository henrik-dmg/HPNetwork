# HPNetwork
![Swift](https://github.com/henrik-dmg/HPNetwork/workflows/Swift/badge.svg)

`HPNetwork` is a protocol-based networking stack written in pure Swift

## Posting Request

To submit a request, you can use the singleton:
```swift
Network.shared.schedule(request) { result in
    switch result {
    case .success(let output):
        // handle result
    case .failure(let error):
        // handle error
    }
}
```
of with the convenience method:
```swift
request.schedule { result in
	// Handle result
}
```
The `result` is `Result<Request.Output, Error>` where `Request.Output` is inferred from the request object.
`Network.shared` will do its networking on “com.henrikpanhans.Network” (which is a concurrent queue). If you want to use a custom queue, you can pass it in the initialiser:

```swift
let customQueue = DispatchQueue(label: "com.henrikpanhans.CustomQueue", qos: .userInitiated, attributes: .concurrent)
let network = Network(queue: customQueue)
```

You can limit the maximum number of concurrent requests to be executed by settings `Network.shared.maximumConcurrentRequests = 5` for example

## Creating Requests

### Basics
HPNetwork is following a rather protocol based approach, so any type that conforms to `NetworkRequest` can be scheduled as a request. In the most simple terms, that means you supply a `URL` and a request method. 

#### Example 1:
```swift
struct BasicDataRequest: NetworkRequest {

    typealias Output = Data
    
    var url: URL? {
        // construct your URL here
    }
    
    var requestMethod: NetworkRequestMethod {
        .get
    }

}
```

### Example 2:
```swift
struct BasicDataRequest: NetworkRequest {

    typealias Output = Data

    let url: URL?
    let requestMethod: NetworkRequestMethod

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

    let url: URL?
    let requestMethod: NetworkRequestMethod
    
    var decoder: JSONDecoder {
        JSONDecoder() // use default or custom decoder
    }

}
```

### Combine
You can also call `dataTaskPublisher()` on any `NetworkRequest` instance to get a `AnyPublisher<Request.Output, Error`. The publisher will walk through the same validation and error handling process as the regular `Network`.

### Intercepting Errors
By default, instances of `NetworkRequest` will simply forward any encountered errors to the completion block. If you want to do some custom error conversion based on the raw `Data` that was received, you can implement `func convertError(_ error: Error, data: Data?, response: URLResponse?) -> Error` in your request model.

### Everything else
Things like `httpBody: Data?`, `authentication: NetworkRequestAuthentication?` and `headerFields: [NetworkRequestHeaderField]` should be pretty self-explanatory so I'm gonna let you figure those out on your own.

## Progress Callback

You can pass a progress handler block to `Network` like this:
```swift
Network.shared.schedule(request: request) { progress in
    print(progress.fractionComplete)
} completion: { result in
    // Result handling as usual
}
```

## Cancelling Requests

Any call to `schedule(request) { result in ... }` returns an instance of `NetworkTask` that you can cancel by calling `task.cancel()`

## WIP
- [x] Cancellation support
- [x] Progress callback
- [x] Improving the documentation
- [ ] Cookie support
