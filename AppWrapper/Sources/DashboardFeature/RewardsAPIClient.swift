//
//  RewardsApiClient.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/15/25.
//

import Foundation
import ComposableArchitecture
import RewardsAPI
import UIKit

@DependencyClient
public struct RewardsAPIClient {
    public var loadCustomer: @Sendable () async throws -> CustomerEntity
    public var loadAvailablePoints: @Sendable () async throws -> UInt
    public var loadRewards: @Sendable () async throws -> [RewardEntity]
    public var activateReward: @Sendable (String) async throws -> Void
    public var deactivateReward: @Sendable (String) async throws -> Void
    public var getActiveRewardIdentifiers: @Sendable () async throws -> [String]
    public var loadImage: @Sendable (URL) async throws -> UIImage
}

extension RewardsAPIClient: DependencyKey {
    public static let liveValue = Self(
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
        },
        loadImage: { url in
            try await API.shared.loadImage(for: url)
        }
    )
}

public extension DependencyValues {
    var rewardsAPIClient: RewardsAPIClient {
        get { self[RewardsAPIClient.self] }
        set { self[RewardsAPIClient.self] = newValue }
    }
}
