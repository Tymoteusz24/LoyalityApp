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
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEachStore(
                        store.scope(
                            state: \.rewardsSection,
                            action: \.rewardsSection
                        )
                    ) { rewardStore in
                        RewardView(store: rewardStore)
                    }
                }
            }
       
            BannerCodeView()
        }
        .refreshable {
            store.send(.refreshData)
        }
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
            rewardsSection: [
                .mock(id: "1", name: "Free Coffee", pointsCost: 100, buttonState: .readyToCollect),
                .mock(id: "2", name: "Premium Meal", pointsCost: 500, buttonState: .readyToCollect),
                .mock(id: "3", name: "Dessert Special", pointsCost: 250, buttonState: .collected),
                .mock(id: "4", name: "VIP Experience", pointsCost: 2000, buttonState: .locked)
            ]
        ),
        includeReducer: false
    )
}

#Preview("Loading") {
    DashboardView.createPreview(
        initialState: Dashboard.State(
            customerHeader: .loading,
            availablePoints: .loading
        ),
        includeReducer: false
    )
}
#endif
