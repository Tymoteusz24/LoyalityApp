import SwiftUI
import Resources

public struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    var actionOptions = Set(ActionOption.allCases)
    @ViewBuilder var label: () -> Label
    
    public init(
        action: @escaping () async -> Void,
        actionOptions: Set<AsyncButton<Label>.ActionOption> = Set(ActionOption.allCases),
        label: @escaping () -> Label) {
        self.action = action
        self.actionOptions = actionOptions
        self.label = label
    }
    
    @State private var isDisabled = false
    @State private var showProgressView = false
    
    public var body: some View {
        Button(
            action: {
                if actionOptions.contains(.disableIfRunning) {
                    isDisabled = true
                }
                
                Task { @MainActor in
                    if actionOptions.contains(.showProgressView) {
                        showProgressView = true
                    }
                    
                    await action()
                    
                    isDisabled = false
                    showProgressView = false
                }
            },
            label: {
                ZStack {
                    label().opacity(showProgressView ? .zero : 1.0)
                    
                    if showProgressView {
                        ProgressView()
                            .tint(Resource.Color.loaderPrimary.swiftUIColor)
                    }
                }
            }
        )
        .disabled(isDisabled)
    }
}

public extension AsyncButton {
    enum ActionOption: CaseIterable {
        case disableIfRunning
        case showProgressView
    }
}
