import Foundation

/// Pure back/forward navigation history stack for Settings sidebar tabs.
public struct SettingsNavigationHistory<Tab: Hashable & Equatable> {
    public private(set) var stack: [Tab]
    public private(set) var index: Int = 0

    public init(initialTab: Tab) {
        self.stack = [initialTab]
        self.index = 0
    }

    public var current: Tab { stack[index] }
    public var canGoBack: Bool { index > 0 }
    public var canGoForward: Bool { index < stack.count - 1 }

    public mutating func select(_ tab: Tab) {
        guard tab != current else { return }
        if index < stack.count - 1 {
            stack.removeSubrange((index + 1)..<stack.count)
        }
        stack.append(tab)
        index = stack.count - 1
    }

    public mutating func goBack() -> Tab {
        guard canGoBack else { return current }
        index -= 1
        return current
    }

    public mutating func goForward() -> Tab {
        guard canGoForward else { return current }
        index += 1
        return current
    }
}
