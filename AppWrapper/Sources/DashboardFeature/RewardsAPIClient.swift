//
//  RewardsApiClient.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/15/25.
//

import Foundation
import ComposableArchitecture
import Foundation
import RewardsAPI

@DependencyClient
struct RewardsAPIClient {
    var loadCustomer: @Sendable () async throws -> CustomerEntity
    var loadAvailablePoints: @Sendable () async throws -> UInt
    var loadRewards: @Sendable () async throws -> [RewardEntity]
    var activateReward: @Sendable (String) async throws -> Void
    var deactivateReward: @Sendable (String) async throws -> Void
    var getActiveRewardIdentifiers: @Sendable () async throws -> [String]
}

extension RewardsAPIClient: DependencyKey {
    static let liveValue = Self(
        loadCustomer: {
            try await API.shared.loadCustomer()
        },
        loadAvailablePoints: {
            try await API.shared.loadAvailablePoints()
        },
        loadRewards: {
            try await API.shared.loadRewards()
        },
        activateReward: { id in
            try await API.shared.activateReward(with: id)
        },
        deactivateReward: { id in
            try await API.shared.deactivateReward(with: id)
        },
        getActiveRewardIdentifiers: {
            try await API.shared.getActiveRewardIdentifiers()
        }
    )
}

extension DependencyValues {
    var rewardsAPIClient: RewardsAPIClient {
        get { self[RewardsAPIClient.self] }
        set { self[RewardsAPIClient.self] = newValue }
    }
}
