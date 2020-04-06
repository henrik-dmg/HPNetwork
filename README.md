# HPNetwork

`HPNetwork` is a lightweight but customizable network stack.

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

Return type is `Result<NetworkRequest.Output, Error>` where `NetworkRequest.Output` is inferred from the request object

## Creating Requests

You can either use custom request objects like this:

```swift
class IPLocationRequest: NetworkRequest {

    typealias Input = Data
    typealias Output = IPLocation

    let urlString: String = "https://ipapi.co/json"
    let requestMethod: NetworkRequestMethod = .get
    let authentication: NetworkRequestAuthentication? = nil

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

- [ ] Adding ability to add HTTP body data
- [ ] Improving the documentation