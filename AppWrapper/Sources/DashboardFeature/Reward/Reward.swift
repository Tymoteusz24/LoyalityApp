//
//  Reward.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import DataLayer
import Resources

@Reducer
public struct Reward {
    @ObservableState
    public struct State: Equatable, Identifiable {
        public enum ButtonState: Equatable {
            case readyToCollect  // Can afford, available to collect
            case collected       // Already collected/redeemed
            case locked          // Can't afford
        }
        
        public var id: String {
            rewardModel?.id ?? ""
        }
        
        var rewardModel: RewardModel?
        var buttonState: ButtonState
        
        init(rewardModel: RewardModel? = nil, buttonState: ButtonState = .locked) {
            self.rewardModel = rewardModel
            self.buttonState = buttonState
        }
    }
    
    public enum Action: Equatable {
        case activateButtonTapped
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .activateButtonTapped:
                // Don't update state optimistically
                // Let the parent Dashboard reducer handle the API call
                // and reload data to reflect the actual state
                return .none
            }
        }
    }
}
