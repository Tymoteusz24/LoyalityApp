import SwiftUI
import Resources

public extension View {
    func textStyle(_ textStyle: TextStyle) -> some View {
        self
            .font(textStyle.font)
            .lineSpacing(textStyle.lineSpacing)
            .padding(.vertical, textStyle.lineSpacing / 2)
            .kerning(textStyle.kerning)
            .textCase(textStyle.textCase)
            .strikethrough(textStyle.hasStrikethrough)
            .underline(textStyle.hasUnderline)
    }
}

public extension TextStyle {
    enum Header {
        public static let medium = TextStyle(size: 16, font: FontFamily.Montserrat.bold, lineHeight: 20)
        public static let large = TextStyle(size: 24, font: FontFamily.Montserrat.bold, lineHeight: 30)
    }

    enum Body {
        public static let medium = TextStyle(size: 12, font: FontFamily.Montserrat.semiBold, lineHeight: 16)
        public static let large = TextStyle(size: 16, font: FontFamily.Montserrat.regular, lineHeight: 24)
    }
}

public struct TextStyle {
    public let font: SwiftUI.Font
    public let fontName: String
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let lineSpacing: CGFloat
    public let hasStrikethrough: Bool
    public let hasUnderline: Bool
    public let kerning: CGFloat
    public let textCase: Text.Case?
    
    public init(
        size: CGFloat,
        font: FontConvertible,
        lineHeight: CGFloat,
        kerning: CGFloat = .zero,
        hasStrikethrough: Bool = false,
        hasUnderline: Bool = false,
        textCase: Text.Case? = nil
    ) {
        self.font = font.swiftUIFont(size: size)
        self.fontName = font.name
        self.size = size
        self.hasStrikethrough = hasStrikethrough
        self.hasUnderline = hasUnderline
        self.kerning = kerning
        self.lineHeight = lineHeight
        self.lineSpacing = (lineHeight - font.font(size: size).lineHeight)
        self.textCase = textCase
    }
}
