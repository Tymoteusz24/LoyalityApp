import UIKit
import Resources

public struct Appearance {
    public static func setup() {
        UIRefreshControl.appearance().tintColor = Resource.Color.loaderPrimary.color
    }
}
