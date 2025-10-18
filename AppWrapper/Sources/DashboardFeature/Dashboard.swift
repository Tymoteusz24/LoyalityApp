import ComposableArchitecture
import RewardsAPI

@Reducer
public struct Dashboard {
    @ObservableState
    public struct State: Equatable {
        var customerHeader: CustomerHeader.State
        var availablePoints: AvailablePoints.State
        var rewardsSection: IdentifiedArrayOf<Reward.State>
        
        // Store raw rewards data to recalculate button states when points load
        fileprivate var rawRewards: [RewardEntity] = []
        // Track collected reward IDs to preserve collected state
        fileprivate var collectedRewardIds: Set<String> = []
    }
    
    public enum Action {
        case loadData
        
        case customerDataLoaded(Result<CustomerEntity, Error>)
        case availablePointsLoaded(Result<UInt, Error>)
        case rewardsSectionLoaded(Result<[RewardEntity], Error>)
        
        case customerHeader(CustomerHeader.Action)
        case availablePoints(AvailablePoints.Action)
        case rewardsSection(IdentifiedActionOf<Reward>)
    }

    @Dependency(\.rewardsAPIClient) var rewardsAPIClient
    
    public init() {}
    
    // MARK: - public methods
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
                state.customerHeader = CustomerHeader.State.loading
                state.availablePoints = AvailablePoints.State.loading
                state.rewardsSection = IdentifiedArrayOf<Reward.State>()
                state.rawRewards = []
                state.collectedRewardIds = []
                
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
                    },
                    .run { send in
                        await send(
                            .rewardsSectionLoaded(
                                Result {
                                    try await rewardsAPIClient.loadRewards()
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
                // Update rewards section with new available points
                updateRewardsSection(state: &state)
                return .none
                
            case let .availablePointsLoaded(.failure(error)):
                // For available points, we'll keep it in loading state on error
                // Or you can add an error state to AvailablePoints if needed
                print("Error loading available points: \(error.localizedDescription)")
                return .none
            case let .rewardsSectionLoaded(.success(rewards)):
                state.rawRewards = rewards
                updateRewardsSection(state: &state)
                return .none
            case .customerHeader:
                return .none
                
            case .availablePoints:
                return .none
                
            case let .rewardsSection(.element(id: id, action: .activateButtonTapped)):
                // Find the reward that was tapped
                guard let reward = state.rewardsSection[id: id],
                      let rewardModel = reward.rewardModel,
                      reward.buttonState == .collected, // Check if it was just collected
                      case .content(let currentPoints) = state.availablePoints else {
                    return .none
                }
                
                // Mark reward as collected
                state.collectedRewardIds.insert(id)
                
                // Deduct the points
                let newPoints = max(0, currentPoints - rewardModel.pointsCosts)
                state.availablePoints = .content(newPoints)
                
                // Update other rewards' button states based on new points
                updateRewardsSection(state: &state)
                
                return .none
                
            case .rewardsSection:
                return .none
                
            case .rewardsSectionLoaded(.failure(_)):
                return .none
            }
        }
        .forEach(\.rewardsSection, action: \.rewardsSection) {
            Reward()
        }
    }
}

// Mark: - Private methods
extension Dashboard {
    
    // Helper method to update rewards section with current available points
    private func updateRewardsSection(state: inout State) {
        guard !state.rawRewards.isEmpty else { return }
        
        let availablePoints: Int
        if case .content(let points) = state.availablePoints {
            availablePoints = points
        } else {
            availablePoints = 0
        }
        
        state.rewardsSection = IdentifiedArray(uniqueElements: state.rawRewards.map { reward in
            let rewardModel = RewardModel(entity: reward)
            
            // Preserve collected state if reward was already collected
            let buttonState: Reward.State.ButtonState
            if state.collectedRewardIds.contains(reward.id) {
                buttonState = .collected
            } else {
                buttonState = availablePoints >= rewardModel.pointsCosts ? .readyToCollect : .locked
            }
            
            return Reward.State(rewardModel: rewardModel, buttonState: buttonState)
        })
    }
}

// MARK: - Initializers

extension Dashboard.State {
    public init(
        customerHeader: CustomerHeader.State = CustomerHeader.State.loading,
        availablePoints: AvailablePoints.State = AvailablePoints.State.loading,
        rewardsSection: IdentifiedArrayOf<Reward.State> = []
    ) {
        self.customerHeader = customerHeader
        self.availablePoints = availablePoints
        self.rewardsSection = rewardsSection
    }
}
