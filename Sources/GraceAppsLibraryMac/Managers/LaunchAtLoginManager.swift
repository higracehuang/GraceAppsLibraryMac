import Foundation
import ServiceManagement
import SwiftUI

/// Abstract protocol representing the platform service that manages launch-at-login registration.
///
/// Abstracted from `SMAppService` to enable reliable unit testing in sandboxed or CLI environments.
public protocol LaunchAtLoginServiceProtocol {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
    func openSystemSettingsLoginItems()
}

/// Default system implementation of `LaunchAtLoginServiceProtocol` using `SMAppService.mainApp`.
public struct SystemLaunchAtLoginService: LaunchAtLoginServiceProtocol {
    public init() {}

    public var status: SMAppService.Status {
        SMAppService.mainApp.status
    }

    public func register() throws {
        try SMAppService.mainApp.register()
    }

    public func unregister() throws {
        try SMAppService.mainApp.unregister()
    }

    public func openSystemSettingsLoginItems() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

/// Observable manager for macOS launch-at-login via `SMAppService`.
///
/// Manages registration state, gracefully handles sandbox/permission failures, and provides
/// a two-way SwiftUI `Binding<Bool>` for immediate binding into settings UI and onboarding tours.
@MainActor
public final class LaunchAtLoginManager: ObservableObject {
    public static let shared = LaunchAtLoginManager()

    private let service: LaunchAtLoginServiceProtocol

    @Published public private(set) var isEnabled: Bool = false
    @Published public private(set) var status: SMAppService.Status = .notRegistered
    @Published public private(set) var lastError: Error?

    public init(service: LaunchAtLoginServiceProtocol = SystemLaunchAtLoginService()) {
        self.service = service
        self.refresh()
    }

    /// Queries the underlying service to refresh `status` and `isEnabled`.
    public func refresh() {
        let currentStatus = service.status
        self.status = currentStatus
        self.isEnabled = (currentStatus == .enabled)
    }

    /// Indicates whether the login item is registered but requires user approval in System Settings.
    public var requiresApproval: Bool {
        status == .requiresApproval
    }

    /// Registers the main application as a login item.
    @discardableResult
    public func register() throws -> Bool {
        do {
            try service.register()
            lastError = nil
            refresh()
            return isEnabled
        } catch {
            lastError = error
            refresh()
            throw error
        }
    }

    /// Unregisters the main application as a login item.
    @discardableResult
    public func unregister() throws -> Bool {
        do {
            try service.unregister()
            lastError = nil
            refresh()
            return isEnabled
        } catch {
            lastError = error
            refresh()
            throw error
        }
    }

    /// Sets whether the app should launch at login. Catches any error and updates `lastError`.
    ///
    /// - Parameter enable: `true` to register, `false` to unregister.
    /// - Returns: `true` if the operation succeeded and the current state matches the requested state.
    @discardableResult
    public func setEnabled(_ enable: Bool) -> Bool {
        do {
            if enable {
                try register()
            } else {
                try unregister()
            }
            return isEnabled == enable
        } catch {
            return false
        }
    }

    /// Two-way binding for SwiftUI controls.
    ///
    /// When the toggle value is changed, attempts registration or unregistration and
    /// resets immediately to the real system status if an error occurs.
    public var binding: Binding<Bool> {
        Binding(
            get: { self.isEnabled },
            set: { [weak self] newValue in
                self?.setEnabled(newValue)
            }
        )
    }

    /// Opens macOS System Settings -> General -> Login Items & Extensions.
    public func openSystemSettings() {
        service.openSystemSettingsLoginItems()
    }
}
