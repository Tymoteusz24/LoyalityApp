//
//  ImageLoader.swift
//  Networking
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Foundation
import ComposableArchitecture
import RewardsAPI
import UIKit

@DependencyClient
public struct ImageLoader {
    public var loadImage: @Sendable (URL) async throws -> UIImage
}

extension ImageLoader: DependencyKey {
    public static let liveValue = Self(
        loadImage: { url in
            try await API.shared.loadImage(for: url)
        }
    )
}

public extension DependencyValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoader.self] }
        set { self[ImageLoader.self] = newValue }
    }
}

