import ComposableArchitecture

@Reducer
public struct Dashboard {
    @ObservableState
    public struct State: Equatable {
        var customerHeader: CustomerHeader.State
        var availablePoints: AvailablePoints.State
    }
    
    public enum Action {
        case loadData
        case customerHeader(CustomerHeader.Action)
        case availablePoints(AvailablePoints.Action)
    }

    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(
            state: \.customerHeader,
            action: \.customerHeader
        ) {
            CustomerHeader()
        }
        Scope(
            state: \.availablePoints,
            action: \.availablePoints
        ) {
            AvailablePoints()
        }
        Reduce {
            state,
            action in
            switch action {
            case .loadData:
                return .none
            }
        }
    }
}

extension Dashboard.State {
    public init(
        customerHeader: CustomerHeader.State = .loading,
        availablePoints: AvailablePoints.State = .loading
    ) {
        self.customerHeader = customerHeader
        self.availablePoints = availablePoints
    }
}
