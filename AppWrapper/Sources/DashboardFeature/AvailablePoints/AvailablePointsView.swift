import ComposableArchitecture
import UI
import Resources
import Localizations
import SwiftUI

struct AvailablePointsView: View {
    let store: StoreOf<AvailablePoints>
    
    var body: some View {
        content
            .padding(.top, Margin.small)
            .padding(.horizontal)
    }
}

private extension AvailablePointsView {
    var content: some View {
        HStack {
            Image(asset: Resource.Image.loop)
            VStack(alignment: .leading) {
                switch store.state {
                case .loading:
                    progressView
                case let .content(points):
                    pointsView(points)
                case .error:
                    Text(Localized.errorAlertTitle)
                        .textStyle(.Header.medium)
                }
            }
            Spacer()
        }
    }
    
    var progressView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(Resource.Color.loaderPrimary.swiftUIColor)
            Spacer()
        }
    }
    
    func pointsView(_ points: Int) -> some View {
        VStack(alignment: .leading) {
            Group {
                Text("\(points) ").foregroundColor(Resource.Color.points.swiftUIColor) + Text(Localized.dashboardPointsSuffix)
            }
            .textStyle(.Header.large)
            .foregroundStyle(Resource.Color.counterLoopPointsSuffix.swiftUIColor)
            
            message
        }
    }
    
    var message: some View {
        Text(Localized.dashboardReedemPointsMessage)
            .textStyle(.Body.medium)
            .foregroundStyle(Resource.Color.counterLoopSubtitle.swiftUIColor)
    }
}

#if DEBUG
private extension AvailablePointsView {
    static func createPreview(initialState: AvailablePoints.State) -> Self {
        .init(
            store: Store(initialState: initialState) {
                AvailablePoints()
            }
        )
    }
}
#Preview("Content") {
    AvailablePointsView.createPreview(initialState: .content(1650))
}
#Preview("Loading") {
    AvailablePointsView.createPreview(initialState: .loading)
}
#endif
