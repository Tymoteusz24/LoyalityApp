//
//  CustomerRemoteRepository.swift
//  Networking
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Foundation
import ComposableArchitecture
import RewardsAPI

@DependencyClient
public struct CustomerRemoteRepository {
    public var loadCustomer: @Sendable () async throws -> CustomerModel
    public var loadAvailablePoints: @Sendable () async throws -> UInt
}

extension CustomerRemoteRepository: DependencyKey {
    public static let liveValue = Self(
        loadCustomer: {
            let entity = try await API.shared.loadCustomer()
            return CustomerModel(entity: entity)
        },
        loadAvailablePoints: {
            try await API.shared.loadAvailablePoints()
        }
    )
}

public extension DependencyValues {
    var customerRemoteRepository: CustomerRemoteRepository {
        get { self[CustomerRemoteRepository.self] }
        set { self[CustomerRemoteRepository.self] = newValue }
    }
}

