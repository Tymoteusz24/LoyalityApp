//
//  RewardsRemoteRepository.swift
//  Networking
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Foundation
import ComposableArchitecture
import RewardsAPI

@DependencyClient
public struct RewardsRemoteRepository {
    public var loadRewards: @Sendable () async throws -> [RewardModel]
    public var activateReward: @Sendable (String) async throws -> Void
    public var deactivateReward: @Sendable (String) async throws -> Void
    public var getActiveRewardIdentifiers: @Sendable () async throws -> [String]
}

extension RewardsRemoteRepository: DependencyKey {
    public static let liveValue = Self(
        loadRewards: {
            let entities = try await API.shared.loadRewards()
            return entities.map { RewardModel(entity: $0) }
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

public extension DependencyValues {
    var rewardsRemoteRepository: RewardsRemoteRepository {
        get { self[RewardsRemoteRepository.self] }
        set { self[RewardsRemoteRepository.self] = newValue }
    }
}

