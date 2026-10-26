import Foundation

/// GraceAppsLibraryMac: shared code for Grace's macOS apps.
///
/// macOS-only by design. There is no platform-conditional compilation
/// in this package: no UIKit, no iOS-only APIs. If a feature only
/// exists on iOS, it does not belong here.
///
/// This library is the intended long-term replacement for
/// SolicitReviewLibrary in the Mac apps. SolicitReviewLibrary is still
/// in use today (FaceCam uses it); apps migrate to
/// `ReviewPromptManager` here when they are ready, and SolicitReviewLibrary
/// is retired only after every Mac app has switched.
public enum GraceAppsLibraryMac {
    /// The library's own version, independent of any host app's version.
    public static let version = "1.0.0"
}
