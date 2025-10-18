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
        case refreshData
        
        case customerDataLoaded(Result<CustomerEntity, Error>)
        case availablePointsLoaded(Result<UInt, Error>)
        case rewardsSectionLoaded(Result<[RewardEntity], Error>)
        case activeRewardsLoaded(Result<[String], Error>)
        
        case rewardActivated(Result<Void, Error>)
        case rewardDeactivated(Result<Void, Error>)
        
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
                // if we got some errors, just refresh parts that contains error, if no error states load all data again
            case .refreshData:
                var effects: [Effect<Action>] = []
                
                if case .error = state.customerHeader {
                    state.customerHeader = .loading
                    effects.append(
                        .run { send in
                            await send(
                                .customerDataLoaded(
                                    Result {
                                        try await rewardsAPIClient.loadCustomer()
                                    }
                                )
                            )
                        }
                    )
                }
                
                if case .error = state.availablePoints {
                    state.availablePoints = .loading
                    effects.append(
                        .run { send in
                            await send(
                                .availablePointsLoaded(
                                    Result {
                                        try await rewardsAPIClient.loadAvailablePoints()
                                    }
                                )
                            )
                        }
                    )
                }
                
                if effects.count > 0 {
                    // If there were errors in header or points, just reload those
                    return .merge(effects)
                } else {
                    // load all data again
                    return .send(.loadData)
                }
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
                    },
                    .run { send in
                        await send(
                            .activeRewardsLoaded(
                                Result {
                                    try await rewardsAPIClient.getActiveRewardIdentifiers()
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
                
            case let .availablePointsLoaded(.failure(_)):
                state.availablePoints = .error
                return .none
            case let .rewardsSectionLoaded(.success(rewards)):
                state.rawRewards = rewards
                updateRewardsSection(state: &state)
                return .none
                
            case let .activeRewardsLoaded(.success(activeIds)):
                state.collectedRewardIds = Set(activeIds)
                updateRewardsSection(state: &state)
                return .none
                
            case let .activeRewardsLoaded(.failure(error)):
                print("Error loading active rewards: \(error.localizedDescription)")
                return .none
                
            case .rewardActivated(.success):
                // After successful activation, reload active rewards and available points
                return .merge(
                    .run { send in
                        await send(
                            .activeRewardsLoaded(
                                Result {
                                    try await rewardsAPIClient.getActiveRewardIdentifiers()
                                }
                            )
                        )
                    },
                    .run { send in
                        await send(
                            .availablePointsLoaded(
                                Result {
                                    try await rewardsAPIClient.loadAvailablePoints()
                                }
                            )
                        )
                    }
                )
                
            case let .rewardActivated(.failure(error)):
                print("Error activating reward: \(error.localizedDescription)")
                // TODO: Could add error handling/UI feedback here
                return .none
                
            case .rewardDeactivated(.success):
                // After successful deactivation, reload active rewards and available points
                return .merge(
                    .run { send in
                        await send(
                            .activeRewardsLoaded(
                                Result {
                                    try await rewardsAPIClient.getActiveRewardIdentifiers()
                                }
                            )
                        )
                    },
                    .run { send in
                        await send(
                            .availablePointsLoaded(
                                Result {
                                    try await rewardsAPIClient.loadAvailablePoints()
                                }
                            )
                        )
                    }
                )
                
            case let .rewardDeactivated(.failure(error)):
                print("Error deactivating reward: \(error.localizedDescription)")
                // TODO: Could add error handling/UI feedback here
                return .none
                
            case .customerHeader:
                return .none
                
            case .availablePoints:
                return .none
                
            case let .rewardsSection(.element(id: id, action: .activateButtonTapped)):
                // Find the reward that was tapped
                guard let reward = state.rewardsSection[id: id] else {
                    return .none
                }
                
                // Check current state to determine if activating or deactivating
                // The Reward reducer has already updated the buttonState locally
                if reward.buttonState == .collected {
                    // Just collected - call activate API, then reload data
                    return .run { send in
                        await send(
                            .rewardActivated(
                                Result {
                                    try await rewardsAPIClient.activateReward(id)
                                }
                            )
                        )
                    }
                } else if reward.buttonState == .readyToCollect {
                    // Just uncollected - call deactivate API, then reload data
                    return .run { send in
                        await send(
                            .rewardDeactivated(
                                Result {
                                    try await rewardsAPIClient.deactivateReward(id)
                                }
                            )
                        )
                    }
                }
                
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
