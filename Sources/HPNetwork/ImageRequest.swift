#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class ImageDownloadRequest: NetworkRequest {

    #if canImport(UIKit)
    public typealias Output = UIImage
    #elseif canImport(AppKit)
    public typealias Output = NSImage
    #endif

    public let url: URL?
    public let urlSession: URLSession
    public let finishingQueue: DispatchQueue
    public let requestMethod: NetworkRequestMethod
    public let authentication: NetworkRequestAuthentication?

    public init(
        url: URL?,
        urlSession: URLSession = .shared,
        finishingQueue: DispatchQueue = .main,
        requestMethod: NetworkRequestMethod = .get,
        authentication: NetworkRequestAuthentication? = nil)
    {
        self.url = url
        self.urlSession = urlSession
        self.finishingQueue = finishingQueue
        self.requestMethod = requestMethod
        self.authentication = authentication
    }

}
