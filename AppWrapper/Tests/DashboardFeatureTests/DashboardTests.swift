import ComposableArchitecture
import DataLayer
import RewardsAPI
import Testing

@testable import DashboardFeature

@Suite("Dashboard Reducer Tests")
@MainActor
struct DashboardTests {
    
    // MARK: - Load Data Tests
    
    @Test("All sections show error when all data fails to load")
    func allDataLoadingFails() async {
        let store = TestStore(initialState: Dashboard.State()) {
            Dashboard()
        } withDependencies: {
            $0.customerRemoteRepository.loadCustomer = {
                try? await Task.sleep(nanoseconds: 0)
                throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Customer load failed"])
            }
            $0.customerRemoteRepository.loadAvailablePoints = {
                try? await Task.sleep(nanoseconds: 1_00_000_000)
                throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Points load failed"])
            }
            $0.rewardsRemoteRepository.loadRewards = {
                try? await Task.sleep(nanoseconds: 2_00_000_000)
                throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Rewards load failed"])
            }
            $0.rewardsRemoteRepository.getActiveRewardIdentifiers = {
                try? await Task.sleep(nanoseconds: 3_00_000_000)
                throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Active rewards load failed"])
            }
        }
        
        await store.send(.loadData)
        
        // Customer load fails
        await store.receive { action in
            guard case .dataLoading(.customerDataLoaded(.failure)) = action else {
                return false
            }
            return true
        } assert: {
            $0.customerHeader = .error("Customer load failed")
        }
        
        // Points load fails
        await store.receive { action in
            guard case .dataLoading(.availablePointsLoaded(.failure)) = action else {
                return false
            }
            return true
        } assert: {
            $0.availablePoints = .error
        }
        
        // Rewards load fails
        await store.receive { action in
            guard case .dataLoading(.rewardsSectionLoaded(.failure)) = action else {
                return false
            }
            return true
        } assert: {
            $0.rewardsSection = .error
        }
        
        // Active rewards load fails (no state change since rewardsSection is already .error)
        await store.receive { action in
            guard case .dataLoading(.activeRewardsLoaded(.failure)) = action else {
                return false
            }
            return true
        }
        
        // Verify all sections are in error state
        #expect(store.state.customerHeader == .error("Customer load failed"))
        #expect(store.state.availablePoints == .error)
        #expect(store.state.rewardsSection == .error)
        #expect(store.state.rawRewards.isEmpty)
        #expect(store.state.collectedRewardIds.isEmpty)
    }
    
    @Test("Rewards section shows error when active rewards fail to load")
    func activeRewardsFailureCausesErrorState() async {
        let mockCustomer = CustomerEntity(name: "John Doe")
        let mockRewards = [
            RewardEntity(
                id: "1",
                name: "Free Coffee",
                coverURL: URL(string: "https://example.com/coffee.jpg")!,
                pointsCost: 100
            ),
            RewardEntity(
                id: "2",
                name: "Premium Meal",
                coverURL: URL(string: "https://example.com/meal.jpg")!,
                pointsCost: 500
            )
        ]
        let mockPoints: UInt = 250
        
        let store = TestStore(initialState: Dashboard.State()) {
            Dashboard()
        } withDependencies: {
            $0.customerRemoteRepository.loadCustomer = {
                try? await Task.sleep(nanoseconds: 0)
                return CustomerModel(name: mockCustomer.name)
            }
            $0.customerRemoteRepository.loadAvailablePoints = {
                try? await Task.sleep(nanoseconds: 1_00_000_000)
                return mockPoints
            }
            $0.rewardsRemoteRepository.loadRewards = {
                try? await Task.sleep(nanoseconds: 2_00_000_000)
                return mockRewards.map { RewardModel(entity: $0) }
            }
            $0.rewardsRemoteRepository.getActiveRewardIdentifiers = {
                // Active rewards endpoint fails
                try? await Task.sleep(nanoseconds: 3_00_000_000)
                throw NSError(domain: "TestError", code: 500)
            }
        }
        
        await store.send(.loadData)
        
        await store.receive { action in
            guard case .dataLoading(.customerDataLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.customerHeader = .content("John Doe")
        }
        
        await store.receive { action in
            guard case .dataLoading(.availablePointsLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.availablePoints = .content(250)
        }
        
        // Rewards load successfully
        await store.receive { action in
            guard case .dataLoading(.rewardsSectionLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.rawRewards = mockRewards.map { RewardModel(entity: $0) }
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[0]),
                    buttonState: .readyToCollect
                ),
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[1]),
                    buttonState: .locked
                )
            ]))
        }
        
        // BUT active rewards fail - should set rewards section to error
        await store.receive { action in
            guard case .dataLoading(.activeRewardsLoaded(.failure)) = action else {
                return false
            }
            return true
        } assert: {
            // Even though rewards loaded successfully, we show error state
            // because we can't reliably show which rewards are collected
            $0.rewardsSection = .error
        }
    }
    
    @Test("Check load data handles active rewards loaded before rewards")
    func activeRewardsLoadedBeforeRewards() async {
        let mockCustomer = CustomerEntity(name: "John Doe")
        let mockRewards = [
            RewardEntity(
                id: "1",
                name: "Free Coffee",
                coverURL: URL(string: "https://example.com/coffee.jpg")!,
                pointsCost: 100
            ),
            RewardEntity(
                id: "2",
                name: "Premium Meal",
                coverURL: URL(string: "https://example.com/meal.jpg")!,
                pointsCost: 500
            )
        ]
        let mockActiveIds = ["1"]
        let mockPoints: UInt = 250
        
        let store = TestStore(initialState: Dashboard.State()) {
            Dashboard()
        } withDependencies: {
            $0.customerRemoteRepository.loadCustomer = {
                try? await Task.sleep(nanoseconds: 0)
                return CustomerModel(name: mockCustomer.name)
            }
            $0.customerRemoteRepository.loadAvailablePoints = {
                try? await Task.sleep(nanoseconds: 1_00_000_000)
                return mockPoints
            }
            $0.rewardsRemoteRepository.loadRewards = {
                // Rewards load slower (after active rewards)
                try? await Task.sleep(nanoseconds: 3_00_000_000)
                return mockRewards.map { RewardModel(entity: $0) }
            }
            $0.rewardsRemoteRepository.getActiveRewardIdentifiers = {
                // Active rewards load faster (before rewards)
                try? await Task.sleep(nanoseconds: 2_00_000_000)
                return mockActiveIds
            }
        }
        
        await store.send(.loadData)
        
        await store.receive { action in
            guard case .dataLoading(.customerDataLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.customerHeader = .content("John Doe")
        }
        
        await store.receive { action in
            guard case .dataLoading(.availablePointsLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.availablePoints = .content(250)
        }
        
        // Active rewards arrive BEFORE rewards list
        await store.receive { action in
            guard case .dataLoading(.activeRewardsLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.collectedRewardIds = Set(mockActiveIds)
            // Rewards section should still be loading since rewards haven't arrived yet
            // The updateRewardsSection only runs when rawRewards is not empty
        }
        
        // Now rewards arrive
        await store.receive { action in
            guard case .dataLoading(.rewardsSectionLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.rawRewards = mockRewards.map { RewardModel(entity: $0) }
            // Now that rewards have arrived, they should be properly updated with collected state
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[0]),
                    buttonState: .collected  // Should be collected since active IDs were already loaded
                ),
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[1]),
                    buttonState: .locked
                )
            ]))
        }
    }
    
    @Test("Check load data update successfully collected state when active rewards are loaded after rewards")
    func loadDataSuccess() async {
        let mockCustomer = CustomerEntity(name: "John Doe")
        let mockRewards = [
            RewardEntity(
                id: "1",
                name: "Free Coffee",
                coverURL: URL(string: "https://example.com/coffee.jpg")!,
                pointsCost: 100
            ),
            RewardEntity(
                id: "2",
                name: "Premium Meal",
                coverURL: URL(string: "https://example.com/meal.jpg")!,
                pointsCost: 500
            )
        ]
        let mockActiveIds = ["1"]
        let mockPoints: UInt = 250
        
        let store = TestStore(initialState: Dashboard.State()) {
            Dashboard()
        } withDependencies: {
            $0.customerRemoteRepository.loadCustomer = {
                try? await Task.sleep(nanoseconds: 0)
                return CustomerModel(name: mockCustomer.name)
            }
            $0.customerRemoteRepository.loadAvailablePoints = {
                try? await Task.sleep(nanoseconds: 1_00_000_000)
                return mockPoints
            }
            $0.rewardsRemoteRepository.loadRewards = {
                try? await Task.sleep(nanoseconds: 2_00_000_000)
                return mockRewards.map { RewardModel(entity: $0) }
            }
            $0.rewardsRemoteRepository.getActiveRewardIdentifiers = {
                try? await Task.sleep(nanoseconds: 3_00_000_000)
                return mockActiveIds
            }
        }
        
        await store.send(.loadData)
        
        await store.receive { action in
            guard case .dataLoading(.customerDataLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.customerHeader = .content("John Doe")
        }
        
        await store.receive { action in
            guard case .dataLoading(.availablePointsLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.availablePoints = .content(250)
        }
        
        await store.receive { action in
            guard case .dataLoading(.rewardsSectionLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[0]),
                    buttonState: .readyToCollect
                ),
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[1]),
                    buttonState: .locked
                )
            ]))
            $0.rawRewards = mockRewards.map { RewardModel(entity: $0) }
        }
 
        // testing the rewards with collected state
        await store.receive { action in
            guard case .dataLoading(.activeRewardsLoaded(.success)) = action else {
                return false
            }
            return true
        } assert: {
            $0.collectedRewardIds = Set(mockActiveIds)
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[0]),
                    buttonState: .collected
                ),
                Reward.State(
                    rewardModel: RewardModel(entity: mockRewards[1]),
                    buttonState: .locked
                )
            ]))
        }
        
    }
}

