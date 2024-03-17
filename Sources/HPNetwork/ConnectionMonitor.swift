import Foundation
import Network

public final class ConnectionMonitor: ObservableObject {

    // MARK: - Properties

    public static let connectionBecameSatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionBecameUnsatisfiedNotification = Notification.Name("ConnectionBecameSatisfiedNotification")
    public static let connectionRequiresConnectionNoticication = Notification.Name("ConnectionRequiresConnectionNoticication")
    public static let updatedPathKey = "ConnectionMonitorUpdatedPathKey"

    @Published public private(set) var currentPath: NWPath

    private let pathMonitor: NWPathMonitor

    // MARK: - Init

    public convenience init(requiredInterfaceType: NWInterface.InterfaceType) {
        self.init(pathMonitor: NWPathMonitor(requiredInterfaceType: requiredInterfaceType))
    }

    public convenience init() {
        self.init(pathMonitor: NWPathMonitor())
    }

    private init(
        pathMonitor: NWPathMonitor,
        queue: DispatchQueue = DispatchQueue(label: "dev.panhans.ConnectionMonitor", qos: .background)
    ) {
        self._currentPath = Published(initialValue: pathMonitor.currentPath)
        self.pathMonitor = pathMonitor

        self.pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.emitNotification(path)
        }
        self.pathMonitor.start(queue: queue)
    }

    // MARK: - State Changes

    private func emitNotification(_ path: NWPath) {
        print("Updated")
        let userInfo = [ConnectionMonitor.updatedPathKey: path]

        currentPath = path

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

}
