//
//  RewardModel.swift
//  Networking
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Foundation
import RewardsAPI

public struct RewardModel: Equatable, Sendable {
    public let id: String
    public let name: String
    public let coverURL: URL
    public let pointsCosts: Int
    
    public init(id: String, name: String, coverURL: URL, pointsCosts: Int) {
        self.id = id
        self.name = name
        self.coverURL = coverURL
        self.pointsCosts = pointsCosts
    }
    
    init(entity: RewardEntity) {
        self.id = entity.id
        self.name = entity.name
        self.coverURL = entity.coverURL
        self.pointsCosts = Int(entity.pointsCost)
    }
}

