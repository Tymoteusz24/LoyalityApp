import ComposableArchitecture
import DataLayer
import RewardsAPI
import Testing

@testable import DashboardFeature

@Suite("Dashboard Reducer Tests")
@MainActor
struct DashboardTests {
    
    // MARK: - Load Data Tests
    
    @Test("Load data successfully with all API calls succeeding")
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

