import SwiftUI

/// A simple list of Grace's Mac apps, for an About or Settings screen.
/// Tapping an app opens its Mac App Store page. The host app is
/// excluded by passing its own App Store ID.
public struct GraceAppsView: View {
    private let apps: [GraceMacApp]

    public init(excludingAppStoreId: String? = nil) {
        self.apps = GraceMacApp.all(excludingAppStoreId: excludingAppStoreId)
    }

    public var body: some View {
        List(apps) { app in
            Link(destination: app.appStoreURL) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.headline)
                    Text(app.shortDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("More from Grace")
    }
}
