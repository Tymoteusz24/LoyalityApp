import ComposableArchitecture
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
            $0.rewardsAPIClient.loadCustomer = {
                try? await Task.sleep(nanoseconds: 0)
                return mockCustomer
            }
            $0.rewardsAPIClient.loadAvailablePoints = {
                try? await Task.sleep(nanoseconds: 1_00_000_000)
                return mockPoints }
            $0.rewardsAPIClient.loadRewards = {
                try? await Task.sleep(nanoseconds: 2_00_000_000)
                return mockRewards }
            $0.rewardsAPIClient.getActiveRewardIdentifiers = {
                try? await Task.sleep(nanoseconds: 3_00_000_000)
                return mockActiveIds }
        }
        
        await store.send(.loadData)
        
        await store.receive(\.customerDataLoaded.success) {
            $0.customerHeader = .content("John Doe")
        }
        
        await store.receive(\.availablePointsLoaded.success) {
            $0.availablePoints = .content(250)
        }
        
        await store.receive(\.rewardsSectionLoaded.success) {
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(
                        entity: mockRewards[0]
                    ),
                    buttonState: .readyToCollect,
                ),
                Reward.State(
                    rewardModel: RewardModel(
                        entity: mockRewards[1]
                    ),
                    buttonState: .locked
                )
            ]))
            $0.rawRewards = mockRewards
        }
 
        
        await store.receive(\.activeRewardsLoaded.success) {
            $0.collectedRewardIds = ["1"]
            $0.rewardsSection = .content(IdentifiedArray(uniqueElements: [
                Reward.State(
                    rewardModel: RewardModel(
                        entity: mockRewards[0]
                    ),
                    buttonState: .collected,
                ),
                Reward.State(
                    rewardModel: RewardModel(
                        entity: mockRewards[1]
                    ),
                    buttonState: .locked
                )
            ]))
        }
        
    }
}

