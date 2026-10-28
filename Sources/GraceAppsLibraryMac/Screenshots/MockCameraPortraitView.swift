import SwiftUI

/// Renders a studio developer portrait inside preview shapes and bubbles during screenshot captures,
/// ensuring marketing captures look polished even when no physical webcam is connected or in headless runs.
public struct MockCameraPortraitView: View {
    public let isMirrored: Bool

    public init(isMirrored: Bool = false) {
        self.isMirrored = isMirrored
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.16, blue: 0.28),
                        Color(red: 0.11, green: 0.12, blue: 0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image("DeveloperProfilePicture", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(x: isMirrored ? -1 : 1, y: 1)
                    .clipped()
            }
        }
    }
}
