import Foundation
import Network

public final class ConnectionMonitor {

    // MARK: - Properties

    public static let `default` = ConnectionMonitor()
    public static let connectionBecameSatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionBecameUnsatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionRequiresConnectionNoticication = Notification.Name("ConnectionRequiresConnectionNoticication")
    public static let updatedPathKey = "ConnectionMonitorUpdatedPathKey"

    private let pathMonitor: NWPathMonitor

    public var pathUpdateHandler: ((NWPath) -> Void)?
    public private(set) var isMonitoring = false

    public var currentPath: NWPath? {
        isMonitoring ? pathMonitor.currentPath : nil
    }

    // MARK: - Init

    public convenience init(requiredInterfaceType: NWInterface.InterfaceType) {
        self.init(pathMonitor: NWPathMonitor(requiredInterfaceType: requiredInterfaceType))
    }

    public convenience init() {
        self.init(pathMonitor: NWPathMonitor())
    }

    private init(pathMonitor: NWPathMonitor) {
        self.pathMonitor = pathMonitor
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.emitNotification(path)
        }
    }

    // MARK: - State Changes

    private func emitNotification(_ path: NWPath) {
        let userInfo = [ConnectionMonitor.updatedPathKey: path]

        switch path.status {
        case .satisfied:
            NotificationCenter.default.post(
                name: ConnectionMonitor.connectionBecameSatisfiedNotification,
                object: self,
                userInfo: userInfo
            )
        case .unsatisfied:
            NotificationCenter.default.post(
                name: ConnectionMonitor.connectionBecameUnsatisfiedNotification,
                object: self,
                userInfo: userInfo
            )
        case .requiresConnection:
            NotificationCenter.default.post(
                name: ConnectionMonitor.connectionRequiresConnectionNoticication,
                object: self,
                userInfo: userInfo
            )
        @unknown default:
            break
        }
    }

    // MARK: - Notifications

    public func startMonitoring(on queue: DispatchQueue = .init(label: "dev.panhans.ConnectionMonitor", qos: .background)) {
        pathMonitor.start(queue: queue)
        isMonitoring = true
    }

    public func stopMonitoring() {
        pathMonitor.cancel()
        isMonitoring = false
    }

}
