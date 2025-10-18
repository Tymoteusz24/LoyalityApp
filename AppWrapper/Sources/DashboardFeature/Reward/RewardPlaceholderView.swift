//
//  RewardPlaceholderView.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import Foundation
import Resources
import SwiftUI
import UI

public struct RewardPlaceholderView: View {
   
    typealias Constants = LoyalityCardConstants
    
    public init() {}
    
    public var body: some View {
        
        VStack {
            // Image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: Constants.photoHeight)
                .shimmer()
            
            Group {
                Spacer()
                
                // Title placeholder
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 20)
                    .shimmer()
                
                Spacer()
                
                // Button placeholder
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: Constants.buttonWidth,
                        height: Constants.buttonHeight
                    )
                    .padding(.bottom, Margin.big)
                    .shimmer()
            }
        }
        .frame(
            width: Constants.cardWidth,
            height: Constants.cardHeight
        )
        .background(Resource.Color.cardLockedBackground.swiftUIColor.opacity(0.5))
        .cornerRadius(CornerRadius.small)
        .padding(.horizontal, Margin.small)
    }
}

#if DEBUG
#Preview {
    HStack {
        RewardPlaceholderView()
        RewardPlaceholderView()
        RewardPlaceholderView()
    }
}
#endif

