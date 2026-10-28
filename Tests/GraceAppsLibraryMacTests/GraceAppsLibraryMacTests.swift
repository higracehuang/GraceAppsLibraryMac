import XCTest
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
}
