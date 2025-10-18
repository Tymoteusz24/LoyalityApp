import ComposableArchitecture
import UI
import Resources
import Localizations
import SwiftUI

struct BannerCodeView: View {
    var body: some View {
        ZStack {
            viewGradient
            banner
        }
        .padding(.vertical)
    }
}

private extension BannerCodeView {
    private enum Constants {
        static let bannerHeight: CGFloat = 152.0
        static let buttonWidth: CGFloat = 240.0
        static let buttonHeight: CGFloat = 40.0
    }
    
    var viewGradient: some View {
        GradientView(
            colors: [
                Resource.Color.gradientSecondaryStart.swiftUIColor,
                Resource.Color.gradientSecondaryEnd.swiftUIColor
            ]
        )
        .cornerRadius(Margin.medium)
        .padding(.horizontal)
        .frame(height: Constants.bannerHeight)
    }
    
    var banner: some View {
        VStack(spacing: Margin.medium) {
            bannerTitle
            bannerMessage
            bannerButton
        }
    }
    
    var bannerTitle: some View {
        Text(Localized.dashboardBottomBannerTitle)
            .textStyle(.Header.medium)
            .foregroundStyle(Resource.Color.bannerCodeTitle.swiftUIColor)
    }
    
    var bannerMessage: some View {
        Text(Localized.dashboardBottomBannerMessage)
            .textStyle(.Body.medium)
            .foregroundStyle(Resource.Color.bannerCodeMessage.swiftUIColor)
    }
    
    var bannerButton: some View {
        Button(
            action: {},
            label: {
                Text(Localized.dashboardBottomBannerButtonTitle)
                    .textStyle(.Header.medium)
                    .foregroundStyle(Resource.Color.buttonActiveText.swiftUIColor)
                    .frame(
                        width: Constants.buttonWidth,
                        height: Constants.buttonHeight
                    )
                    .foregroundColor(Resource.Color.backgroundPrimary.swiftUIColor)
                    .primaryGradientBackground()
            }
        )
    }
    
    var bannerGradient: some View {
        GradientView(
            colors: [
                Resource.Color.gradientPrimaryStart.swiftUIColor,
                Resource.Color.gradientPrimaryEnd.swiftUIColor
            ]
        )
        .cornerRadius(CornerRadius.medium)
    }
}

#if DEBUG
#Preview {
    BannerCodeView()
}
#endif
