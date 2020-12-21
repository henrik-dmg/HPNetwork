# HPNetwork
![Swift](https://github.com/henrik-dmg/HPNetwork/workflows/Swift/badge.svg)

`HPNetwork` is a lightweight but customizable network stack.

## Attention: HPNetwork is currently under heavy development
Most of the refactor on the road to `v1.0` is done, but I still need to write documentation and the API may introduce breaking changes even in minor patches.

## Posting Request

To submit a request, use the singleton

```swift
Network.shared.send(request) { result in
   // ...
}
```

or submit a custom `URLSession` instance

```swift
let session = URLSession(...)
Network(session: session).send(request) { result in
   // ...
}
```

Return type is `Result<DataRequest.Output, Error>` where `DataRequest.Output` is inferred from the request object

## Creating Requests

You can either use custom request objects like this:

```swift
class IPLocationRequest: DataRequest {

    typealias Input = Data
    typealias Output = IPLocation

    let urlString: String = "https://ipapi.co/json"
    let requestMethod: DataRequestMethod = .get
    let authentication: DataRequestAuthentication? = nil
    let headerFields: [DataRequestHeaderField]? = nil

}
```

Or if you're simply trying to `Decodable` types from a server, you can use `DecodableRequest<Decodable>` directly like so:

```swift
DecodableRequest<IPLocation>(
   urlString: "https://ipapi.co/json",
	requestMethod: .get,
	authentication: .basic(username: someUsername, password: userPassword))
```

## Cancelling Requests

Any call to `send(request) { result in ... }` returns an instance of `NetworkTask` that you can cancel by calling `task.cancel()`

## WIP
- [ ] Cancellation support
- [ ] Cookie support
- [ ] Improving the documentation
