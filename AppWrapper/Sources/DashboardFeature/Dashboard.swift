import ComposableArchitecture
import DataLayer

@Reducer
public struct Dashboard {
    @ObservableState
    public struct State: Equatable {
        var customerHeader: CustomerHeader.State
        var availablePoints: AvailablePoints.State
        var rewardsSection: RewardsSection
        
        // Store raw rewards data to recalculate button states when points load
        var rawRewards: [RewardModel] = []
        // Track collected reward IDs to preserve collected state
        var collectedRewardIds: Set<String> = []
        
        // Error toast state
        var errorToast: String?
    }
    
    public enum Action {
        // Lifecycle actions
        case loadData
        case refreshData
        
        // Data loading actions
        case dataLoading(DataLoadingAction)
        
        // Reward management actions
        case rewardManagement(RewardManagementAction)
        
        // Error handling
        case dismissErrorToast
        
        // Child reducer actions
        case customerHeader(CustomerHeader.Action)
        case availablePoints(AvailablePoints.Action)
        case rewardsSection(IdentifiedActionOf<Reward>)
    }
    
    public enum DataLoadingAction {
        case customerDataLoaded(Result<CustomerModel, Error>)
        case availablePointsLoaded(Result<UInt, Error>)
        case rewardsSectionLoaded(Result<[RewardModel], Error>)
        case activeRewardsLoaded(Result<[String], Error>)
    }
    
    public enum RewardManagementAction {
        case rewardActivated(Result<Void, Error>)
        case rewardDeactivated(Result<Void, Error>)
    }

    @Dependency(\.customerRemoteRepository) var customerRemoteRepository
    @Dependency(\.rewardsRemoteRepository) var rewardsRemoteRepository
    
    public init() {}
    
    // MARK: - Reducer Body
    public var body: some ReducerOf<Self> {
        Scope(state: \.customerHeader, action: \.customerHeader) {
            CustomerHeader()
        }
        Scope(state: \.availablePoints, action: \.availablePoints) {
            AvailablePoints()
        }
        
        Reduce { state, action in
            switch action {
            case .loadData:
                return handleLoadData(state: &state)
                
            case .refreshData:
                return handleRefreshData(state: &state)
                
            case let .dataLoading(dataAction):
                return handleDataLoading(action: dataAction, state: &state)
                
            case let .rewardManagement(rewardAction):
                return handleRewardManagement(action: rewardAction, state: &state)
                
            case .dismissErrorToast:
                state.errorToast = nil
                return .none
                
            case .customerHeader, .availablePoints:
                return .none
                
            case let .rewardsSection(.element(id: id, action: .activateButtonTapped)):
                return handleRewardTap(id: id, state: &state)
                
            case .rewardsSection:
                return .none
            }
        }
        .ifLet(\.rewardsSectionContent, action: \.rewardsSection) {
            EmptyReducer()
                .forEach(\.self, action: \.self) {
                    Reward()
                }
        }
    }
}

// MARK: - Lifecycle Handlers
extension Dashboard {
    private func handleLoadData(state: inout State) -> Effect<Action> {
        state.customerHeader = .loading
        state.availablePoints = .loading
        state.rewardsSection = .loading
        state.rawRewards = []
        state.collectedRewardIds = []
        
        return .merge(
            loadCustomerEffect(),
            loadAvailablePointsEffect(),
            loadRewardsEffect(),
            loadActiveRewardsEffect()
        )
    }
    
    private func handleRefreshData(state: inout State) -> Effect<Action> {
        var effects: [Effect<Action>] = []
        
        if case .error = state.customerHeader {
            state.customerHeader = .loading
            effects.append(loadCustomerEffect())
        }
        
        if case .error = state.availablePoints {
            state.availablePoints = .loading
            effects.append(loadAvailablePointsEffect())
        }
        
        if case .error = state.rewardsSection {
            state.rewardsSection = .loading
            state.rawRewards = []
            state.collectedRewardIds = []
            effects.append(loadRewardsEffect())
            effects.append(loadActiveRewardsEffect())
        }
        
        return effects.isEmpty ? .send(.loadData) : .merge(effects)
    }
}

// MARK: - Effect Creators
extension Dashboard {
    private func loadCustomerEffect() -> Effect<Action> {
        .run { send in
            await send(
                .dataLoading(.customerDataLoaded(
                    Result { try await customerRemoteRepository.loadCustomer() }
                ))
            )
        }
    }
    
    private func loadAvailablePointsEffect() -> Effect<Action> {
        .run { send in
            await send(
                .dataLoading(.availablePointsLoaded(
                    Result { try await customerRemoteRepository.loadAvailablePoints() }
                ))
            )
        }
    }
    
    private func loadRewardsEffect() -> Effect<Action> {
        .run { send in
            await send(
                .dataLoading(.rewardsSectionLoaded(
                    Result { try await rewardsRemoteRepository.loadRewards() }
                ))
            )
        }
    }
    
    private func loadActiveRewardsEffect() -> Effect<Action> {
        .run { send in
            await send(
                .dataLoading(.activeRewardsLoaded(
                    Result { try await rewardsRemoteRepository.getActiveRewardIdentifiers() }
                ))
            )
        }
    }
    
    private func reloadAfterRewardChange() -> Effect<Action> {
        .merge(
            loadActiveRewardsEffect(),
            loadAvailablePointsEffect()
        )
    }
}

// MARK: - Data Loading Handler
extension Dashboard {
    private func handleDataLoading(
        action: DataLoadingAction,
        state: inout State
    ) -> Effect<Action> {
        switch action {
        case let .customerDataLoaded(.success(customerModel)):
            state.customerHeader = .content(customerModel.name)
            return .none
            
        case let .customerDataLoaded(.failure(error)):
            state.customerHeader = .error(error.localizedDescription)
            return .none
            
        case let .availablePointsLoaded(.success(points)):
            state.availablePoints = .content(Int(points))
            updateRewardsSection(state: &state)
            return .none
            
        case .availablePointsLoaded(.failure):
            // maybe we can use some error pareser to show different error states
            // perform crashlytics non-fatal error logging here
            state.availablePoints = .error
            return .none
            
        case let .rewardsSectionLoaded(.success(rewards)):
            state.rawRewards = rewards
            updateRewardsSection(state: &state)
            return .none
            
        case .rewardsSectionLoaded(.failure):
            // maybe we can use some error pareser to show different error states
            // perform crashlytics non-fatal error logging here
            state.rewardsSection = .error
            return .none
            
        case let .activeRewardsLoaded(.success(activeIds)):
            state.collectedRewardIds = Set(activeIds)
            updateRewardsSection(state: &state)
            return .none
        
        // if we fail loading active rewards, we don't want toshow rewards section so user is not misled
        case let .activeRewardsLoaded(.failure(error)):
            state.rewardsSection = .error
            return .none
        }
    }
}

// MARK: - Reward Management Handler
extension Dashboard {
    private func handleRewardManagement(
        action: RewardManagementAction,
        state: inout State
    ) -> Effect<Action> {
        switch action {
        case .rewardActivated(.success), .rewardDeactivated(.success):
            state.errorToast = nil
            return reloadAfterRewardChange()
            
        case let .rewardActivated(.failure(error)):
            state.errorToast = "Failed to activate reward"
            // perform crashlytics non-fatal error logging here
            // Reload data to revert UI to actual state
            return reloadAfterRewardChange()
            
        case let .rewardDeactivated(.failure(error)):
            state.errorToast = "Failed to deactivate reward"
            // perform crashlytics non-fatal error logging here
            // Reload data to revert UI to actual state
            return reloadAfterRewardChange()
        }
    }
    
    private func handleRewardTap(id: String, state: inout State) -> Effect<Action> {
        guard case .content(let rewards) = state.rewardsSection,
              let reward = rewards[id: id] else {
            return .none
        }
        
        // Check the current state (no optimistic update anymore)
        // If readyToCollect, user wants to collect -> activate
        // If collected, user wants to uncollect -> deactivate
        switch reward.buttonState {
        case .readyToCollect:
            return activateRewardEffect(id: id)
            
        case .collected:
            return deactivateRewardEffect(id: id)
            
        case .locked:
            return .none
        }
    }
    
    private func activateRewardEffect(id: String) -> Effect<Action> {
        .run { send in
            await send(
                .rewardManagement(.rewardActivated(
                    Result { try await rewardsRemoteRepository.activateReward(id) }
                ))
            )
        }
    }
    
    private func deactivateRewardEffect(id: String) -> Effect<Action> {
        .run { send in
            await send(
                .rewardManagement(.rewardDeactivated(
                    Result { try await rewardsRemoteRepository.deactivateReward(id) }
                ))
            )
        }
    }
}

// MARK: - State Updates
extension Dashboard {
    private func updateRewardsSection(state: inout State) {
        guard !state.rawRewards.isEmpty else { return }
        
        let availablePoints: Int
        if case .content(let points) = state.availablePoints {
            availablePoints = points
        } else {
            availablePoints = 0
        }
        
        let rewards = IdentifiedArray(uniqueElements: state.rawRewards.map { rewardModel in
            let buttonState: Reward.State.ButtonState
            if state.collectedRewardIds.contains(rewardModel.id) {
                buttonState = .collected
            } else {
                buttonState = availablePoints >= rewardModel.pointsCosts ? .readyToCollect : .locked
            }
            
            return Reward.State(rewardModel: rewardModel, buttonState: buttonState)
        })
        
        state.rewardsSection = .content(rewards)
    }
}

// MARK: - Computed Properties
extension Dashboard.State {
    var rewardsSectionContent: IdentifiedArrayOf<Reward.State>? {
        get {
            guard case .content(let rewards) = rewardsSection else { return nil }
            return rewards
        }
        set {
            guard let newValue else {
                rewardsSection = .loading
                return
            }
            rewardsSection = .content(newValue)
        }
    }
}

// MARK: - Initializers

extension Dashboard.State {
    public init(
        customerHeader: CustomerHeader.State = CustomerHeader.State.loading,
        availablePoints: AvailablePoints.State = AvailablePoints.State.loading,
        rewardsSection: RewardsSection = .loading,
        errorToast: String? = nil
    ) {
        self.customerHeader = customerHeader
        self.availablePoints = availablePoints
        self.rewardsSection = rewardsSection
        self.errorToast = errorToast
    }
}
