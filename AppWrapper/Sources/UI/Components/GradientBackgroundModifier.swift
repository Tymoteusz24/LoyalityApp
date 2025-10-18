//
//  GradientBackgroundModifier.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 10/18/25.
//

import SwiftUI
import Resources

public struct PrimaryGradientBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    let gradientDirection: GradientView.Direction
    
    public init(
        cornerRadius: CGFloat = CornerRadius.medium,
        gradientDirection: GradientView.Direction = .rightToLeft
    ) {
        self.cornerRadius = cornerRadius
        self.gradientDirection = gradientDirection
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                GradientView(
                    gradientDirection: gradientDirection,
                    colors: [
                        Resource.Color.gradientPrimaryStart.swiftUIColor,
                        Resource.Color.gradientPrimaryEnd.swiftUIColor
                    ]
                )
                .cornerRadius(cornerRadius)
            )
    }
}

public struct SecondaryGradientBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat
    let gradientDirection: GradientView.Direction
    
    public init(
        cornerRadius: CGFloat = CornerRadius.medium,
        gradientDirection: GradientView.Direction = .rightToLeft
    ) {
        self.cornerRadius = cornerRadius
        self.gradientDirection = gradientDirection
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                GradientView(
                    gradientDirection: gradientDirection,
                    colors: [
                        Resource.Color.gradientSecondaryStart.swiftUIColor,
                        Resource.Color.gradientSecondaryEnd.swiftUIColor
                    ]
                )
                .cornerRadius(cornerRadius)
            )
    }
}

public extension View {
    /// Adds a primary gradient background with corner radius
    /// - Parameters:
    ///   - cornerRadius: The corner radius to apply (default: CornerRadius.medium)
    ///   - gradientDirection: The direction of the gradient (default: .rightToLeft)
    /// - Returns: A view with primary gradient background
    func primaryGradientBackground(
        cornerRadius: CGFloat = CornerRadius.medium,
        gradientDirection: GradientView.Direction = .rightToLeft
    ) -> some View {
        modifier(PrimaryGradientBackgroundModifier(
            cornerRadius: cornerRadius,
            gradientDirection: gradientDirection
        ))
    }
    
    /// Adds a secondary gradient background with corner radius
    /// - Parameters:
    ///   - cornerRadius: The corner radius to apply (default: CornerRadius.medium)
    ///   - gradientDirection: The direction of the gradient (default: .rightToLeft)
    /// - Returns: A view with secondary gradient background
    func secondaryGradientBackground(
        cornerRadius: CGFloat = CornerRadius.medium,
        gradientDirection: GradientView.Direction = .rightToLeft
    ) -> some View {
        modifier(SecondaryGradientBackgroundModifier(
            cornerRadius: cornerRadius,
            gradientDirection: gradientDirection
        ))
    }
    
    /// Conditionally applies a modifier
    /// - Parameters:
    ///   - condition: The condition to check
    ///   - transform: The transform to apply if condition is true
    /// - Returns: Either the modified view or the original view
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

