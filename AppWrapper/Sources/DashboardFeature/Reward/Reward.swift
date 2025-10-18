//
//  Reward.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import RewardsAPI
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
}

struct RewardModel: Equatable {
    let id: String
    let name: String
    let coverURL: URL
    let pointsCosts: Int
    
    init(entity: RewardEntity) {
        self.id = entity.id
        self.name = entity.name
        
        // Fix incomplete URLs by adding https:// scheme if missing
        let urlString = entity.coverURL.absoluteString
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            self.coverURL = entity.coverURL
        } else {
            // Add https:// scheme to incomplete URLs
            self.coverURL = URL(string: "https://\(urlString)") ?? entity.coverURL
        }
        
        self.pointsCosts = Int(entity.pointsCost)
    }
}
