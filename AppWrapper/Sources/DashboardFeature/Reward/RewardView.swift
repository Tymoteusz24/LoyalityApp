import Localizations
import Resources
import SwiftUI
import UI

struct RewardView: View {    
    var body: some View {
        VStack {
            ZStack {
                rewardImage
                Resource.Color.cardUnlockedImageOverlay.swiftUIColor
            }
            .frame(height: Constants.photoHeight)

            Group {
                Spacer()
                rewardLabel
                Spacer()
                rewardButton
                    .cornerRadius(CornerRadius.medium)
                    .padding(.bottom, Margin.big)
            }
        }
        .frame(
            width: Constants.cardWidth,
            height: Constants.cardHeight
        )
        .background(Resource.Color.cardUnlockedBackground.swiftUIColor)
        .cornerRadius(CornerRadius.small)
        .padding(.horizontal, Margin.small)
    }
}

private extension RewardView {
    enum Constants {
        static let photoHeight: CGFloat = 170.0
        static let buttonWidth: CGFloat = 120.0
        static let buttonHeight: CGFloat = 32.0
        static let cardWidth: CGFloat = 200.0
        static let cardHeight: CGFloat = 286.0
    }

    var rewardImage: some View {
        Image(asset: Resource.Image.placeholder)
            .resizable()
            .scaledToFill()
            .clipped()
    }
    
    var rewardLabel: some View {
        Text("Main reward")
            .textStyle(.Header.medium)
            .foregroundStyle(Resource.Color.cardUnlockedTitle.swiftUIColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Margin.regular)
    }
    
    var rewardButton: some View {
        AsyncButton() {
        } label: {
            rewardButtonContent
        }
    }
    
    var rewardButtonContent: some View {
        HStack {
            Image(uiImage: Resource.Image.padlockUnlocked.image)
            Text("\(100) \(Localized.dashboardPointsSuffix)")
                .textStyle(.Body.medium)
                .foregroundStyle(Resource.Color.buttonUnlockedText.swiftUIColor)
        }
        .frame(
            width: Constants.buttonWidth,
            height: Constants.buttonHeight
        )
        .background(
            GradientView(
                colors: [Resource.Color.buttonUnlockedBackground.swiftUIColor]
            )
        )
    }
}

#if DEBUG
#Preview {
    RewardView()
}
#endif
