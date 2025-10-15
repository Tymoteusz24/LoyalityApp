import ComposableArchitecture
import UI
import Resources
import Localizations
import SwiftUI

struct CustomerHeaderView: View {
    let store: StoreOf<CustomerHeader>
    
    var body: some View {
        content
            .padding(.top, Margin.big)
            .padding(.horizontal)
    }
}

private extension CustomerHeaderView {
    var content: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: .zero) {
                switch store.state {
                case .loading:
                    progressView
                case let .content(name):
                    welcomeTitle(name)
                    welcomeSubitlte
                case let .error(error):
                    errorView(error)
                }
            }
            Spacer()
            cardButton
        }
    }
    
    var progressView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(Resource.Color.loaderPrimary.swiftUIColor)
            Spacer()
        }
        .padding(.vertical, Margin.medium)
    }
    
    func errorView(_ error: String) -> some View {
        HStack {
            Spacer()
            VStack {
                Text(Localized.errorAlertTitle + ": \(error.description)")
                    .textStyle(.Header.medium)
                    .foregroundStyle(Resource.Color.bannerCodeTitle.swiftUIColor)
                    .multilineTextAlignment(.center)
                Text(Localized.errorAlertMessage)
                    .textStyle(.Body.medium)
                    .foregroundStyle(Resource.Color.bannerCodeMessage.swiftUIColor)
            }
            Spacer()
        }
    }
    
    func welcomeTitle(_ customerName: String) -> some View {
        Text(Localized.dashboardWelcomeTitle(customerName))
            .textStyle(.Header.large)
            .foregroundStyle(Resource.Color.sectionTitleTitle.swiftUIColor)
    }
    
    var welcomeSubitlte: some View {
        Text(Localized.dashboardWelcomeSubtitle)
            .textStyle(.Body.large)
            .foregroundStyle(Resource.Color.sectionTitleSubtitle.swiftUIColor)
    }
    
    var cardButton: some View {
        Button {
            
        } label: {
            Image(asset: Resource.Image.card)
        }
    }
}

#if DEBUG
private extension CustomerHeaderView {
    static func createPreview(initialState: CustomerHeader.State) -> Self {
        .init(
            store: Store(initialState: initialState) {
                CustomerHeader()
            }
        )
    }
}

#Preview {
    CustomerHeaderView.createPreview(initialState: .mock(name: "User"))
}

#Preview("Loading") {
    CustomerHeaderView.createPreview(initialState: .loading)
}

#Preview("Error") {
    CustomerHeaderView.createPreview(initialState: .error("Error message"))
}
#endif
