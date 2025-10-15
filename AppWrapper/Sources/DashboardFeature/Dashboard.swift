import ComposableArchitecture
import RewardsAPI

@Reducer
public struct Dashboard {
    @ObservableState
    public struct State: Equatable {
        var customerHeader: CustomerHeader.State
        var availablePoints: AvailablePoints.State
    }
    
    public enum Action {
        case loadData
        case customerDataLoaded(Result<CustomerEntity, Error>)
        case availablePointsLoaded(Result<UInt, Error>)
        case customerHeader(CustomerHeader.Action)
        case availablePoints(AvailablePoints.Action)
    }

    @Dependency(\.rewardsAPIClient) var rewardsAPIClient
    
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
                state.customerHeader = .loading
                state.availablePoints = .loading
                
                return .merge(
                    .run { send in
                        await send(
                            .customerDataLoaded(
                                Result {
                                    try await rewardsAPIClient.loadCustomer()
                                }
                            )
                        )
                    },
                    .run { send in
                        await send(
                            .availablePointsLoaded(
                                Result {
                                    let awaitRestult = try await rewardsAPIClient.loadAvailablePoints()
                                   return awaitRestult
                                }
                            )
                        )
                    }
                )
                
            case let .customerDataLoaded(.success(customer)):
                state.customerHeader = .content(customer.name)
                return .none
                
            case let .customerDataLoaded(.failure(error)):
                state.customerHeader = .error(error.localizedDescription)
                return .none
                
            case let .availablePointsLoaded(.success(points)):
                state.availablePoints = .content(Int(points))
                return .none
                
            case let .availablePointsLoaded(.failure(error)):
                // For available points, we'll keep it in loading state on error
                // Or you can add an error state to AvailablePoints if needed
                print("Error loading available points: \(error.localizedDescription)")
                return .none
                
            case .customerHeader:
                return .none
                
            case .availablePoints:
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
