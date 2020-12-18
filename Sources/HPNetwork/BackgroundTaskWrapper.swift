import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#endif

struct BackgroundTaskWrapper {

	#if os(iOS) || os(tvOS)
    let backgroundTaskID: UIBackgroundTaskIdentifier?
    #endif

    init() {
		#if os(iOS) || os(tvOS)
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        #endif
    }

}
