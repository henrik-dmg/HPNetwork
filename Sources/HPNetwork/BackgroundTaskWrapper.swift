import Foundation
#if os(iOS)
import UIKit
#endif

struct BackgroundTaskWrapper {

    #if os(iOS)
    let backgroundTaskID: UIBackgroundTaskIdentifier?
    #endif

    init() {
        #if os(iOS)
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif
    }

}
