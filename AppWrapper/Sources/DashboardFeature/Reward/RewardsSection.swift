
//
//  RewardsSection.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import ComposableArchitecture

@ObservableState
public enum RewardsSection: Equatable {
    case loading
    case content(IdentifiedArrayOf<Reward.State>)
    case error
}

