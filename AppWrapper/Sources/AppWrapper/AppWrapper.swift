import DashboardFeature
import ComposableArchitecture
import SwiftUI
import UI

public struct AppWrapper: App {
    public init() {
        Appearance.setup()
    }

    private let store = Store(
        initialState: Dashboard.State(),
        reducer: { Dashboard() }
    )

    public var body: some Scene {
        WindowGroup {
            DashboardView(store: store)
        }
    }
}
