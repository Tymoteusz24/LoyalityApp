//
//  Reward.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import Foundation

#if DEBUG
extension Reward.State {
    public static func mock(
        id: String = "1",
        name: String = "Free Coffee",
        coverURL: URL = URL(string: "https://picsum.photos/200/300")!,
        pointsCost: Int = 100,
        buttonState: Reward.State.ButtonState = .readyToCollect
    ) -> Self {
        .init(
            rewardModel: RewardModel(
                id: id,
                name: name,
                coverURL: coverURL,
                pointsCosts: pointsCost
            ),
            buttonState: buttonState
        )
    }
}

extension RewardModel {
    init(id: String, name: String, coverURL: URL, pointsCosts: Int) {
        self.id = id
        self.name = name
        self.coverURL = coverURL
        self.pointsCosts = pointsCosts
    }
}
#endif

