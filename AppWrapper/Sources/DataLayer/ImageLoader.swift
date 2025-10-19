//
//  ImageLoader.swift
//  DataLayer
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
            try await loadImageWithRetry(url: url, maxAttempts: 3)
        }
    )
    
    private static func loadImageWithRetry(
        url: URL,
        maxAttempts: Int,
        currentAttempt: Int = 1
    ) async throws -> UIImage {
        do {
            return try await API.shared.loadImage(for: url)
        } catch {
            // If we haven't exhausted all attempts, retry
            if currentAttempt < maxAttempts {
                // Exponential backoff: 0.5s, 1s
                let delay = Double(currentAttempt - 1) * 0.5
                if delay > 0 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
                return try await loadImageWithRetry(
                    url: url,
                    maxAttempts: maxAttempts,
                    currentAttempt: currentAttempt + 1
                )
            }
            // If all attempts failed, throw the error
            throw error
        }
    }
}

public extension DependencyValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoader.self] }
        set { self[ImageLoader.self] = newValue }
    }
}

