import Foundation
import Network

@available(OSX 10.14, iOS 12.0, watchOS 5.0, tvOS 12.0, *)
public final class ConnectionMonitor {

    // MARK: - Properties

    public static let `default` = ConnectionMonitor()
    public static let connectionBecameSatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionBecameUnsatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionRequiresConnectionNoticication = Notification.Name("ConnectionRequiresConnectionNoticication")
    public static let keyForPathObjectInNotifications = "updatedPathKey"

    private let pathMonitor: NWPathMonitor

    public var pathUpdateHandler: ((NWPath) -> Void)?
    public private(set) var isMonitoring = false

    public var currentPath: NWPath? {
        isMonitoring ? pathMonitor.currentPath : nil
    }

    // MARK: - Init

    public init(requiredInterfaceType: NWInterface.InterfaceType) {
        pathMonitor = NWPathMonitor(requiredInterfaceType: requiredInterfaceType)
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.emitNotification(path)
            self?.pathUpdateHandler?(path)
        }
    }

    public init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.emitNotification(path)
            self?.pathUpdateHandler?(path)
        }
    }

    // MARK: - State Changes

    private func emitNotification(_ path: NWPath) {
        let userInfo = [ConnectionMonitor.keyForPathObjectInNotifications: path]

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

    public func startMonitoring(on queue: DispatchQueue = .init(label: "com.henrikpanhans.ConnectionMonitor", qos: .background)) {
        pathMonitor.start(queue: queue)
        isMonitoring = true
    }

    public func stopMonitoring() {
        pathMonitor.cancel()
        isMonitoring = false
    }

}
