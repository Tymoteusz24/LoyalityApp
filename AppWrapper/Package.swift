// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "AppWrapper"

enum Module: String {
    case appWrapper = "AppWrapper"
    case dashboardFeature = "DashboardFeature"
    case dataLayer = "DataLayer"
    case localizations = "Localizations"
    case resources = "Resources"
    case ui = "UI"

    var name: String {
        rawValue
    }
}

let package = Package(
    name: packageName,
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [.app],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.22.2"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2"),
        .package(name: "RewardsAPI", path: "../RewardsAPI")
    ],
    targets: [
        .target(
            name: Module.appWrapper.name,
            dependencies: [
                .module(.dashboardFeature),
                .module(.dataLayer),
                .module(.ui),
            ]
        ),
        .target(
            name: Module.dashboardFeature.name,
            dependencies: [
                .module(.ui),
                .module(.localizations),
                .module(.dataLayer),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: Module.dataLayer.name,
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "RewardsAPI", package: "RewardsAPI"),
            ]
        ),
        .target(
            name: Module.ui.name,
            dependencies: [
                .module(.resources)
            ]
        ),
        .target(
            name: Module.resources.name,
            dependencies: [],
            resources: [
                .process("Fonts")
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .target(
            name: Module.localizations.name,
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .testTarget(
            name: "DashboardFeatureTests",
            dependencies: [
                .module(.dashboardFeature),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        )
    ]
)

extension Product {
    static var app: Product {
        .library(
            name: packageName,
            targets: [packageName]
        )
    }
}

extension Target.Dependency {
    static func module(_ module: Module, condition: TargetDependencyCondition? = nil) -> Target.Dependency {
        .targetItem(name: module.name, condition: condition)
    }
}
