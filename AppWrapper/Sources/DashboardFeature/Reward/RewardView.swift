import Localizations
import Resources
import SwiftUI
import UI
import ComposableArchitecture

struct RewardView: View {
    
    typealias Constants = LoyalityCardConstants
    
    let store: StoreOf<Reward>
    
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

    var rewardImage: some View {
        AsyncImage(url: store.state.rewardModel?.coverURL) { phase in
            switch phase {
            case .empty:
                placeholderImage
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            case .failure:
                placeholderImage
            @unknown default:
                placeholderImage
            }
        }
        .blur(radius: store.state.buttonState == .locked ? 3 : 0)
        .overlay(store.state.buttonState == .locked ? Resource.Color.cardLockedImageOverlay.swiftUIColor : .clear)
        .frame(width: Constants.cardWidth, height: Constants.photoHeight)
        .clipped()
        .background(.black.opacity(0.1))
    }
    
    var placeholderImage: some View {
        Image(asset: Resource.Image.placeholder)
            .clipped()
            .padding()
    }
    
    var rewardLabel: some View {
        Text(store.state.rewardModel?.name ?? "")
            .textStyle(.Header.medium)
            .foregroundStyle(Resource.Color.cardUnlockedTitle.swiftUIColor)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Margin.regular)
    }
    
    var rewardButton: some View {
        AsyncButton() {
            await store.send(.activateButtonTapped).finish()
        } label: {
            rewardButtonContent
        }
        .disabled(store.state.buttonState == .locked)
    }
    
    var rewardButtonContent: some View {
        HStack {
            Image(uiImage: buttonIcon)
            Text("\(store.state.rewardModel?.pointsCosts ?? 0) \(Localized.dashboardPointsSuffix)")
                .textStyle(.Body.medium)
                .foregroundStyle(buttonTextColor)
        }
        .frame(
            width: Constants.buttonWidth,
            height: Constants.buttonHeight
        )
        .background {
            buttonBackground
        }
    }
    
    var buttonIcon: UIImage {
        switch store.state.buttonState {
        case .readyToCollect, .collected:
            return Resource.Image.padlockUnlocked.image
        case .locked:
            return Resource.Image.padlockLocked.image
        }
    }
    
    var buttonTextColor: Color {
        switch store.state.buttonState {
        case .readyToCollect:
            return Resource.Color.buttonActiveText.swiftUIColor
        case .locked:
            return Resource.Color.buttonLockedText.swiftUIColor
        case .collected:
            return Resource.Color.buttonSpecialText.swiftUIColor
        }
    }
    
    @ViewBuilder
    var buttonBackground: some View {
        switch store.state.buttonState {
        case .collected:
            // Ready to collect - primary gradient
            Color.clear
                .primaryGradientBackground(cornerRadius: CornerRadius.medium)
        case .locked:
            // Locked - can't afford
            Resource.Color.buttonLockedBackground.swiftUIColor
                .cornerRadius(CornerRadius.medium)
        case .readyToCollect:
            // Collected - already redeemed, secondary gradient
            Resource.Color.buttonUnlockedBackground.swiftUIColor
                .cornerRadius(CornerRadius.medium)
        }
    }
}

#if DEBUG
#Preview("Ready to Collect") {
    RewardView(
        store: Store(initialState: .mock(
            name: "Free Coffee",
            pointsCost: 100,
            buttonState: .readyToCollect
        )) {
            Reward()
        }
    )
}

#Preview("Locked") {
    RewardView(
        store: Store(initialState: .mock(
            name: "Premium Meal",
            pointsCost: 500,
            buttonState: .locked
        )) {
            Reward()
        }
    )
}

#Preview("Collected") {
    RewardView(
        store: Store(initialState: .mock(
            name: "VIP Experience",
            pointsCost: 1000,
            buttonState: .collected
        )) {
            Reward()
        }
    )
}
#endif
