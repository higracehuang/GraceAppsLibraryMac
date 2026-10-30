import XCTest
import ServiceManagement
import SwiftUI
@testable import GraceAppsLibraryMac

@MainActor
final class GraceAppsLibraryMacTests: XCTestCase {
    private func freshDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return defaults
    }

    func testCatalogHasFourMacAppsWithValidStoreURLs() {
        XCTAssertEqual(GraceMacApp.all.count, 4)
        for app in GraceMacApp.all {
            XCTAssertFalse(app.appStoreId.isEmpty)
            XCTAssertTrue(app.appStoreURL.absoluteString.contains(app.appStoreId))
        }
        XCTAssertEqual(GraceMacApp.all(excludingAppStoreId: "6476702155").count, 3)
        XCTAssertFalse(GraceMacApp.all(excludingAppStoreId: "6476702155").contains { $0.name == "FaceCam" })
    }

    func testReviewURLAcceptsBareAndPrefixedIds() {
        XCTAssertEqual(
            ReviewPromptManager.getReviewURL(appStoreId: "6476702155")?.absoluteString,
            "https://apps.apple.com/app/id6476702155?action=write-review"
        )
        XCTAssertEqual(
            ReviewPromptManager.getReviewURL(appStoreId: "id6476702155")?.absoluteString,
            "https://apps.apple.com/app/id6476702155?action=write-review"
        )
        XCTAssertEqual(
            ReviewPromptManager.getShareURL(appStoreId: "6476702155")?.absoluteString,
            "https://apps.apple.com/app/id6476702155"
        )
    }

    func testReleaseNotesShowOnlyForCurrentVersionOnUpgrade() {
        let defaults = freshDefaults()
        let manager = ReleaseNotesManager(userDefaults: defaults)
        let notes = [ReleaseNote(version: "9.9.9", items: [ReleaseNoteItem(text: "Something new")])]
        // No note matches the test host's version, so never show.
        XCTAssertFalse(manager.shouldShow(releaseNotes: notes))
        XCTAssertFalse(manager.shouldShow(releaseNotes: []))
    }

    func testReleaseNotesManagerMarksVersionAsViewed() {
        let defaults = freshDefaults()
        let manager = ReleaseNotesManager(userDefaults: defaults)
        XCTAssertTrue(manager.isFirstInstall)
        manager.markAsViewed(version: "1.2.3")
        XCTAssertEqual(manager.lastViewedVersion, "1.2.3")
        XCTAssertFalse(manager.isFirstInstall)
    }

    func testReleaseNotesReturningUserGetsNotesOnFirstGALMAdoption() {
        let defaults = freshDefaults()
        let manager = ReleaseNotesManager(userDefaults: defaults)
        let currentVersion = Bundle.main.releaseVersionNumber
        let notes = [ReleaseNote(version: currentVersion, items: [ReleaseNoteItem(text: "New feature")])]

        // When isReturningUser is false on fresh install: suppressed and marked as viewed
        XCTAssertFalse(manager.shouldShow(releaseNotes: notes, isReturningUser: false))
        XCTAssertEqual(manager.lastViewedVersion, currentVersion)

        // Reset state for legacy user test
        manager.resetReleaseNotesState()
        XCTAssertNil(manager.lastViewedVersion)

        // When isReturningUser is true (legacy upgrader with no GALM record): shown!
        XCTAssertTrue(manager.shouldShow(releaseNotes: notes, isReturningUser: true))
        // shouldShow does not mark as viewed for returning users before the view appears
        XCTAssertNil(manager.lastViewedVersion)

        // Once marked as viewed (e.g. by ReleaseNotesView.onAppear): not shown again
        manager.markCurrentVersionAsViewed()
        XCTAssertFalse(manager.shouldShow(releaseNotes: notes, isReturningUser: true))
    }

    func testReleaseNotesClosureOverload() {
        let defaults = freshDefaults()
        let manager = ReleaseNotesManager(userDefaults: defaults)
        let currentVersion = Bundle.main.releaseVersionNumber
        let notes = [ReleaseNote(version: currentVersion, items: [ReleaseNoteItem(text: "New feature")])]

        XCTAssertTrue(manager.shouldShow(releaseNotes: notes, isReturningUser: { true }))
        manager.resetReleaseNotesState()
        XCTAssertFalse(manager.shouldShow(releaseNotes: notes, isReturningUser: { false }))
    }

    func testReviewAppInitResetsCounterOnVersionChange() {
        let defaults = freshDefaults()
        defaults.set(42, forKey: "GraceAppsMac_Review_EngagementCounter")
        defaults.set("0.0.0", forKey: "GraceAppsMac_Review_AppVersionForStorage")
        ReviewPromptManager.appInit(userDefaults: defaults)
        XCTAssertEqual(defaults.integer(forKey: "GraceAppsMac_Review_EngagementCounter"), 0)
        XCTAssertEqual(
            defaults.string(forKey: "GraceAppsMac_Review_AppVersionForStorage"),
            Bundle.main.releaseVersionNumber
        )
    }

    func testReviewManagerHasNotPromptedByDefault() {
        let manager = ReviewPromptManager(userDefaults: freshDefaults())
        XCTAssertFalse(manager.hasPromptYet())
    }

    func testFeedbackToGraceViewDefaultsAndURL() {
        XCTAssertEqual(FeedbackToGraceView.feedbackEmail, "higracehuang@gmail.com")
        XCTAssertFalse(FeedbackToGraceView.feedbackMessage.isEmpty)
        XCTAssertFalse(FeedbackToGraceView.feedbackAppreciation.isEmpty)
        XCTAssertEqual(FeedbackToGraceView.feedbackSignature, "Grace")

        let view = FeedbackToGraceView()
        XCTAssertEqual(view.feedbackURL.scheme, "mailto")
        XCTAssertTrue(view.feedbackURL.absoluteString.contains("higracehuang@gmail.com"))
        XCTAssertEqual(view.effectiveEmail, "higracehuang@gmail.com")
    }

    func testDeveloperProfilePictureAssetExistsInModule() {
        let fileURL = Bundle.module.url(
            forResource: "grace Small",
            withExtension: "jpeg",
            subdirectory: "Assets.xcassets/DeveloperProfilePicture.imageset"
        )
        XCTAssertNotNil(fileURL, "DeveloperProfilePicture asset should exist in module bundle")
    }

    func testSettingsNavigationHistory() {
        var history = SettingsNavigationHistory(initialTab: "general")
        XCTAssertEqual(history.current, "general")
        XCTAssertFalse(history.canGoBack)
        XCTAssertFalse(history.canGoForward)

        history.select("appearance")
        XCTAssertEqual(history.current, "appearance")
        XCTAssertTrue(history.canGoBack)
        XCTAssertFalse(history.canGoForward)

        history.select("shortcuts")
        XCTAssertEqual(history.current, "shortcuts")
        XCTAssertTrue(history.canGoBack)

        XCTAssertEqual(history.goBack(), "appearance")
        XCTAssertTrue(history.canGoBack)
        XCTAssertTrue(history.canGoForward)

        XCTAssertEqual(history.goBack(), "general")
        XCTAssertFalse(history.canGoBack)
        XCTAssertTrue(history.canGoForward)

        XCTAssertEqual(history.goForward(), "appearance")
        XCTAssertTrue(history.canGoBack)
        XCTAssertTrue(history.canGoForward)

        // Selecting a new tab while in the middle clears forward history
        history.select("about")
        XCTAssertEqual(history.current, "about")
        XCTAssertFalse(history.canGoForward)
        XCTAssertTrue(history.canGoBack)
    }

    func testProBadgeRenders() {
        let badge = ProBadge(title: "PRO")
        XCTAssertNotNil(badge)
    }

    func testLaunchAtLoginManagerLifecycle() throws {
        let mock = MockLaunchAtLoginService()
        mock.status = .notRegistered

        let manager = LaunchAtLoginManager(service: mock)
        XCTAssertFalse(manager.isEnabled)
        XCTAssertEqual(manager.status, .notRegistered)
        XCTAssertFalse(manager.requiresApproval)

        // Test register
        let success = try manager.register()
        XCTAssertTrue(success)
        XCTAssertTrue(manager.isEnabled)
        XCTAssertEqual(manager.status, .enabled)

        // Test unregister
        let unregisterSuccess = try manager.unregister()
        XCTAssertFalse(unregisterSuccess)
        XCTAssertFalse(manager.isEnabled)
        XCTAssertEqual(manager.status, .notRegistered)

        // Test setEnabled
        XCTAssertTrue(manager.setEnabled(true))
        XCTAssertTrue(manager.isEnabled)
        XCTAssertTrue(manager.setEnabled(false))
        XCTAssertFalse(manager.isEnabled)

        // Test failure handling
        mock.shouldFailRegister = true
        XCTAssertFalse(manager.setEnabled(true))
        XCTAssertFalse(manager.isEnabled)
        XCTAssertNotNil(manager.lastError)

        // Test binding
        mock.shouldFailRegister = false
        let binding = manager.binding
        binding.wrappedValue = true
        XCTAssertTrue(manager.isEnabled)
        binding.wrappedValue = false
        XCTAssertFalse(manager.isEnabled)

        // Test approval required
        mock.status = .requiresApproval
        manager.refresh()
        XCTAssertTrue(manager.requiresApproval)
        XCTAssertFalse(manager.isEnabled)

        // Test open system settings
        manager.openSystemSettings()
        XCTAssertEqual(mock.openedSystemSettingsCount, 1)

        // Test SwiftUI view init
        let toggleView = LaunchAtLoginToggle("Launch when starting Mac", manager: manager)
        XCTAssertNotNil(toggleView)
    }

    func testDebugSectionsAndMenuView() {
        // Test ReviewPrompt diagnostic properties
        ReviewPromptManager.shared.debugResetReviewState()
        XCTAssertEqual(ReviewPromptManager.shared.debugEngagementCount, 0)
        XCTAssertNil(ReviewPromptManager.shared.debugLastVersionPrompted)

        let reviewSection = DebugReviewPromptSection()
        XCTAssertNotNil(reviewSection)

        let notesSection = DebugReleaseNotesSection(
            releaseNotes: [ReleaseNote(version: "1.0.0", items: [ReleaseNoteItem(text: "Test")])],
            isPaidUser: true
        )
        XCTAssertNotNil(notesSection)

        var didCallResetApp = false
        let resetSection = DebugResetSection {
            didCallResetApp = true
        }
        XCTAssertNotNil(resetSection)
        resetSection.onResetAppDefaults?()
        XCTAssertTrue(didCallResetApp)

        var didCallPaywall = false
        var didCallOnboarding = false
        var didCallReleaseNotes = false
        var didCallFeedback = false
        var didCallReviewPrompt = false

        let flowsSection = DebugFlowsSection(
            presentPaywall: { didCallPaywall = true },
            presentOnboarding: { didCallOnboarding = true },
            presentReleaseNotes: { didCallReleaseNotes = true },
            presentFeedback: { didCallFeedback = true },
            presentReviewPrompt: { didCallReviewPrompt = true }
        )
        XCTAssertNotNil(flowsSection)

        flowsSection.presentPaywall?()
        flowsSection.presentOnboarding?()
        flowsSection.presentReleaseNotes?()
        flowsSection.presentFeedback?()
        flowsSection.presentReviewPrompt?()

        XCTAssertTrue(didCallPaywall)
        XCTAssertTrue(didCallOnboarding)
        XCTAssertTrue(didCallReleaseNotes)
        XCTAssertTrue(didCallFeedback)
        XCTAssertTrue(didCallReviewPrompt)

        // Test combined DebugMenuView
        let debugMenu = DebugMenuView(
            releaseNotes: [ReleaseNote(version: "1.0.0", items: [])],
            presentPaywall: { },
            onResetAppDefaults: { }
        ) {
            Text("Custom App Section")
        }
        XCTAssertNotNil(debugMenu)

        let emptyMenu = DebugMenuView()
        XCTAssertNotNil(emptyMenu)
    }

    func testScreenshotFramework() {
        // Standard presets
        XCTAssertEqual(StandardMacScreenshotPreset.allCases.count, 5)
        XCTAssertEqual(StandardMacScreenshotPreset.from(token: "1"), .slot1Benefit)
        XCTAssertEqual(StandardMacScreenshotPreset.from(token: "benefit"), .slot1Benefit)
        XCTAssertEqual(StandardMacScreenshotPreset.from(token: "5"), .slot5Customization)
        XCTAssertFalse(StandardMacScreenshotPreset.slot1Benefit.suggestedFilename.isEmpty)

        // Language resolution
        XCTAssertEqual(ScreenshotLanguage.from(token: "en"), .english)
        XCTAssertEqual(ScreenshotLanguage.from(token: "zh"), .simplifiedChinese)
        XCTAssertEqual(ScreenshotLanguage.from(token: "zh-Hant"), .traditionalChinese)
        XCTAssertEqual(ScreenshotLanguage.from(token: "de"), .german)
        XCTAssertEqual(ScreenshotLanguage.from(token: "auto"), .auto)
        XCTAssertFalse(ScreenshotLanguage.english.displayName.isEmpty)
        XCTAssertEqual(ScreenshotLanguage.english.appleLanguageCode, "en")

        // Environment parser
        let langFromEnv = ScreenshotLanguage.fromLaunchEnvironment(
            arguments: ["MyApp", "-SCREENSHOT_LANG", "ja"],
            environment: [:]
        )
        XCTAssertEqual(langFromEnv, .japanese)

        let presetFromEnv = StandardMacScreenshotPreset.fromLaunchEnvironment(
            arguments: ["MyApp", "-SCREENSHOT_PRESET", "4"],
            environment: [:]
        )
        XCTAssertEqual(presetFromEnv, .slot4Result)

        // Screenshot engine
        let engine = ScreenshotEngine<StandardMacScreenshotPreset>(
            arguments: ["MyApp", "-SCREENSHOT_PRESET", "2", "-SCREENSHOT_LANG", "de"],
            environment: [:]
        )
        XCTAssertEqual(engine.activePreset, .slot2Feature)
        XCTAssertEqual(engine.selectedLanguage, .german)
        XCTAssertTrue(engine.isScreenshotCaptureActive)

        var didApply = false
        engine.onApply = { _ in didApply = true }
        engine.apply(preset: .slot3SecondFeature)
        XCTAssertTrue(didApply)
        XCTAssertEqual(engine.activePreset, .slot3SecondFeature)

        var didReset = false
        engine.onReset = { didReset = true }
        engine.reset()
        XCTAssertTrue(didReset)
        XCTAssertNil(engine.activePreset)

        // Views
        let portraitView = MockCameraPortraitView(isMirrored: true)
        XCTAssertNotNil(portraitView)

        let debugSection = DebugScreenshotSection(engine: engine)
        XCTAssertNotNil(debugSection)
    }

    func testColorHexExtensions() {
        // Valid 6-char parsing
        let red = Color(hex: "#FF0000")
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.toHex(), "#FF0000")

        let green = Color(hex: "00ff00")
        XCTAssertNotNil(green)
        XCTAssertEqual(green?.toHex(), "#00FF00")

        let blue = Color(hex: "  #0000FF \n")
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue?.toHex(), "#0000FF")

        let peach = Color(hex: "#FFF2D9")
        XCTAssertNotNil(peach)
        XCTAssertEqual(peach?.toHex(), "#FFF2D9")

        // Invalid strings
        XCTAssertNil(Color(hex: ""))
        XCTAssertNil(Color(hex: "#FFF"))
        XCTAssertNil(Color(hex: "#GGGGGG"))
        XCTAssertNil(Color(hex: "#FFFFFFFF")) // Default includeAlpha is false

        // Alpha support
        let semiRed = Color(hex: "#FF000080", includeAlpha: true)
        XCTAssertNotNil(semiRed)
        XCTAssertEqual(semiRed?.toHex(includeAlpha: true), "#FF000080")

        // NSColor
        let nsBlue = NSColor(hex: "#0000FF")
        XCTAssertNotNil(nsBlue)
        XCTAssertEqual(nsBlue?.toHex(), "#0000FF")

        let nsSemi = NSColor(hex: "#00FF0080", includeAlpha: true)
        XCTAssertNotNil(nsSemi)
        XCTAssertEqual(nsSemi?.toHex(includeAlpha: true), "#00FF0080")
    }

    func testDistributionChannelProperties() {
        let store = DistributionChannel.appStore(id: "6476702155")
        XCTAssertTrue(store.isAppStore)
        XCTAssertFalse(store.isDirect)
        XCTAssertEqual(store.appStoreId, "6476702155")

        let direct = DistributionChannel.direct()
        XCTAssertTrue(direct.isDirect)
        XCTAssertFalse(direct.isAppStore)
        XCTAssertNil(direct.appStoreId)

        let customURL = URL(string: "https://gumroad.com/feedback")!
        let directWithURL = DistributionChannel.direct(reviewOrFeedbackURL: customURL)
        XCTAssertTrue(directWithURL.isDirect)
        XCTAssertFalse(directWithURL.isAppStore)
        XCTAssertNil(directWithURL.appStoreId)

        let currentChannel = DistributionChannel.current(appStoreId: "6476702155", directURL: customURL)
        #if DIRECT_DISTRIBUTION
        XCTAssertTrue(currentChannel.isDirect)
        #else
        XCTAssertTrue(currentChannel.isAppStore)
        XCTAssertEqual(currentChannel.appStoreId, "6476702155")
        #endif
    }

    func testReviewPromptManagerChannelBehavior() {
        let manager = ReviewPromptManager(checkpointCount: 1, userDefaults: freshDefaults())

        // App Store channel setup
        manager.appStoreId = "6476702155"
        XCTAssertEqual(manager.channel, .appStore(id: "6476702155"))
        XCTAssertEqual(manager.appStoreId, "6476702155")

        // Switch to direct channel with no feedback URL
        manager.channel = .direct(reviewOrFeedbackURL: nil)
        XCTAssertTrue(manager.channel.isDirect)
        XCTAssertNil(manager.appStoreId)

        // In direct mode without a review/feedback URL, prompts are suppressed
        XCTAssertFalse(manager.requestReviewIfNecessary())
        XCTAssertEqual(manager.debugEngagementCount, 0)
    }

    func testAboutAppSectionViewInitialization() {
        let viewAppStore = AboutAppSectionView(appStoreId: "6476702155")
        XCTAssertNotNil(viewAppStore)

        let viewDirect = AboutAppSectionView(channel: .direct())
        XCTAssertNotNil(viewDirect)

        let viewDirectWithURL = AboutAppSectionView(channel: .direct(reviewOrFeedbackURL: URL(string: "https://example.com/feedback")))
        XCTAssertNotNil(viewDirectWithURL)
    }

    func testFullVersionStatusView() {
        let defaultView = FullVersionStatusView()
        XCTAssertNotNil(defaultView)

        let customView = FullVersionStatusView(title: "Lifetime License", description: "All features unlocked.")
        XCTAssertNotNil(customView)
    }
}

private final class MockLaunchAtLoginService: LaunchAtLoginServiceProtocol {
    var status: ServiceManagement.SMAppService.Status = .notRegistered
    var shouldFailRegister = false
    var shouldFailUnregister = false
    var openedSystemSettingsCount = 0

    func register() throws {
        if shouldFailRegister {
            throw NSError(domain: "test.launchAtLogin", code: 1, userInfo: nil)
        }
        status = .enabled
    }

    func unregister() throws {
        if shouldFailUnregister {
            throw NSError(domain: "test.launchAtLogin", code: 2, userInfo: nil)
        }
        status = .notRegistered
    }

    func openSystemSettingsLoginItems() {
        openedSystemSettingsCount += 1
    }
}
