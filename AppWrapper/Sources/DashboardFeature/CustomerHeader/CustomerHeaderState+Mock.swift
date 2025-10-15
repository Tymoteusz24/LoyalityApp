import Foundation

#if DEBUG
extension CustomerHeader.State {
    public static func mock(name: String = "") -> Self {
        .content(name)
    }
}
#endif
