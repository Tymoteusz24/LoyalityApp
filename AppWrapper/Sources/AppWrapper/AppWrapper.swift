import DashboardFeature
import ComposableArchitecture
import DataLayer
import SwiftUI
import UI

public struct AppWrapper: App {
    @Dependency(\.imageLoader) var imageLoader
    
    public init() {
        Appearance.setup()
    }

    private let store = Store(
        initialState: Dashboard.State(),
        reducer: {
            #if DEBUG
            Dashboard()._printChanges()
            #else
            Dashboard()
            #endif
        }
    )

    public var body: some Scene {
        WindowGroup {
            DashboardView(
                store: store,
                imageLoader: { [imageLoader] url in
                    try await imageLoader.loadImage(url)
                }
            )
        }
    }
}
