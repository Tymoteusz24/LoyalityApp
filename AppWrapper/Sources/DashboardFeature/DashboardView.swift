import ComposableArchitecture
import UI
import Resources
import Localizations
import SwiftUI

public struct DashboardView: View {
    private let store: StoreOf<Dashboard>
    
    public init(store: StoreOf<Dashboard>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            content
                .navigationBarTitle(
                    Localized.dashboardTitle,
                    displayMode: .inline
                )
                .task {
                    await store.send(.loadData).finish()
                }
                .background {
                    gradient
                }
        }
    }
}

private extension DashboardView {
    var content: some View {
        ScrollView {
            CustomerHeaderView(
                store: store.scope(
                    state: \.customerHeader,
                    action: \.customerHeader
                )
            )
            AvailablePointsView(
                store: store.scope(
                    state: \.availablePoints,
                    action: \.availablePoints
                )
            )
            rewardsSection
       
            BannerCodeView()
        }
        .refreshable {
            store.send(.refreshData)
        }
    }
    
    var rewardsSection: some View {
        Group {
            switch store.rewardsSection {
            case .loading:
                rewardsLoadingView
            case .content:
                rewardsContentView
            case .error:
                rewardsErrorView
            }
        }
        .padding(.top, Margin.medium)
    }
    
    var rewardsLoadingView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    RewardPlaceholderView()
                }
            }
            .padding(.horizontal, Margin.small)
        }
    }
    
    @ViewBuilder
    var rewardsContentView: some View {
        if let rewardsStore = store.scope(
            state: \.rewardsSectionContent,
            action: \.rewardsSection
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEachStore(rewardsStore) { rewardStore in
                        RewardView(store: rewardStore)
                    }
                }
                .padding(.horizontal, Margin.small)
            }
        }
    }
    
    var rewardsErrorView: some View {
        VStack(spacing: Margin.medium) {
            Text(Localized.errorAlertTitle)
                .textStyle(.Header.medium)
                .foregroundStyle(Resource.Color.bannerCodeTitle.swiftUIColor)
            Text(Localized.askToRetry)
                .textStyle(.Body.medium)
                .foregroundStyle(Resource.Color.bannerCodeMessage.swiftUIColor)
        }
        .padding(.vertical, Margin.big)
        .padding(.horizontal)
    }
    
    var gradient: some View {
        GradientView(
            gradientDirection: .topToBottom,
            stops: [
                .init(
                    color: Resource.Color.gradientBackgroundStart.swiftUIColor,
                    location: .zero
                ),
                .init(
                    color: Resource.Color.gradientBackgroundEnd.swiftUIColor,
                    location: 0.15
                )
            ]
        )
    }
}

#if DEBUG
private extension DashboardView {
    static func createPreview(initialState: Dashboard.State, includeReducer: Bool = true) -> Self {
        .init(
            store: Store(initialState: initialState) {
                if includeReducer {
                    Dashboard()
                }
            }
        )
    }
}

#Preview("Content") {
    DashboardView.createPreview(
        initialState: Dashboard.State(
            customerHeader: .content("Tymo"),
            availablePoints: .content(1650),
            rewardsSection: .content([
                .mock(id: "1", name: "Free Coffee", pointsCost: 100, buttonState: .readyToCollect),
                .mock(id: "2", name: "Premium Meal", pointsCost: 500, buttonState: .readyToCollect),
                .mock(id: "3", name: "Dessert Special", pointsCost: 250, buttonState: .collected),
                .mock(id: "4", name: "VIP Experience", pointsCost: 2000, buttonState: .locked)
            ])
        ),
        includeReducer: false
    )
}

#Preview("Loading") {
    DashboardView.createPreview(
        initialState: Dashboard.State(
            customerHeader: .loading,
            availablePoints: .loading,
            rewardsSection: .loading
        ),
        includeReducer: false
    )
}

#Preview("Rewards Error") {
    DashboardView.createPreview(
        initialState: Dashboard.State(
            customerHeader: .content("Tymo"),
            availablePoints: .content(1650),
            rewardsSection: .error
        ),
        includeReducer: false
    )
}
#endif
