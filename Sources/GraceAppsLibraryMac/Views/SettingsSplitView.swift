import SwiftUI

/// A ViewModifier that removes the sidebar toggle button on macOS 14+,
/// ensuring the Settings split-view retains its fixed 2-pane layout.
public struct HideSidebarToggleModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.toolbar(removing: .sidebarToggle)
        } else {
            content
        }
    }
}

extension View {
    public func hideSidebarToggle() -> some View {
        modifier(HideSidebarToggleModifier())
    }
}

/// A macOS Settings window split-view container matching macOS Ventura / Sonoma HIG.
/// Provides a fixed sidebar list, forward/back toolbar navigation, grouped form detail styling,
/// and tab identity reset on tab switch.
public struct SettingsSplitView<Tab: Hashable & Identifiable, SidebarLabel: View, Detail: View>: View {
    private let tabs: [Tab]
    @Binding private var selection: Tab
    private let titleForTab: (Tab) -> String
    private let sidebarLabel: (Tab) -> SidebarLabel
    private let detail: (Tab) -> Detail
    private let minSidebarWidth: CGFloat
    private let idealSidebarWidth: CGFloat
    private let maxSidebarWidth: CGFloat

    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var navHistory: SettingsNavigationHistory<Tab>
    @State private var isNavigatingHistory: Bool = false

    public init(
        tabs: [Tab],
        selection: Binding<Tab>,
        titleForTab: @escaping (Tab) -> String,
        minSidebarWidth: CGFloat = 235,
        idealSidebarWidth: CGFloat = 245,
        maxSidebarWidth: CGFloat = 280,
        @ViewBuilder sidebarLabel: @escaping (Tab) -> SidebarLabel,
        @ViewBuilder detail: @escaping (Tab) -> Detail
    ) {
        self.tabs = tabs
        self._selection = selection
        self.titleForTab = titleForTab
        self.minSidebarWidth = minSidebarWidth
        self.idealSidebarWidth = idealSidebarWidth
        self.maxSidebarWidth = maxSidebarWidth
        self.sidebarLabel = sidebarLabel
        self.detail = detail
        self._navHistory = State(initialValue: SettingsNavigationHistory(initialTab: selection.wrappedValue))
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(tabs, selection: $selection) { tab in
                sidebarLabel(tab)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .frame(minWidth: minSidebarWidth, idealWidth: idealSidebarWidth)
            .hideSidebarToggle()
            .navigationSplitViewColumnWidth(min: minSidebarWidth, ideal: idealSidebarWidth, max: maxSidebarWidth)
        } detail: {
            detail(selection)
                .id(selection)
                .formStyle(.grouped)
                .navigationTitle(titleForTab(selection))
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        HStack(spacing: 2) {
                            Button {
                                isNavigatingHistory = true
                                selection = navHistory.goBack()
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                            .disabled(!navHistory.canGoBack)
                            .help("Back")

                            Button {
                                isNavigatingHistory = true
                                selection = navHistory.goForward()
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                            .disabled(!navHistory.canGoForward)
                            .help("Forward")
                        }
                    }
                }
        }
        .onChange(of: selection) { newTab in
            if isNavigatingHistory {
                isNavigatingHistory = false
            } else {
                navHistory.select(newTab)
            }
        }
    }
}
