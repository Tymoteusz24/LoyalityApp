import SwiftUI

public struct GradientView: View {
    public enum Direction {
        case leftToRight
        case rightToLeft
        case bottomToTop
        case topToBottom
    }
    
    private let gradient: Gradient
    private let gradientDirection: Direction
    
    var startPoint: UnitPoint {
        switch gradientDirection {
        case .leftToRight: return .leading
        case .rightToLeft: return .trailing
        case .bottomToTop: return .bottom
        case .topToBottom: return .top
        }
    }
    
    var endPoint: UnitPoint {
        switch gradientDirection {
        case .leftToRight: return .trailing
        case .rightToLeft: return .leading
        case .bottomToTop: return .top
        case .topToBottom: return .bottom
        }
    }
    
    public init(gradientDirection: Direction = .rightToLeft, stops: [Gradient.Stop]) {
        self.gradientDirection = gradientDirection
        self.gradient = Gradient(stops: stops)
    }
    
    public init(gradientDirection: Direction = .rightToLeft, colors: [Color]) {
        self.gradientDirection = gradientDirection
        self.gradient = Gradient(colors: colors)
    }
    
    public var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}
