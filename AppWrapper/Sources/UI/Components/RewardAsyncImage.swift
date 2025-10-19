//
//  RewardAsyncImage.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 11/18/25.
//

import SwiftUI
import UIKit

/// Custom async image loader that uses a provided image loading function
public struct RewardAsyncImage<Content: View, Placeholder: View, ErrorView: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    let errorView: (Error) -> ErrorView
    let imageLoader: (URL) async throws -> UIImage
    let cache: ImageCacheProtocol
    
    @State private var phase: AsyncImagePhase = .loading
    
    public var body: some View {
        Group {
            switch phase {
            case .loading:
                placeholder()
            case .success(let image):
                content(image)
            case .failure(let error):
                errorView(error)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        // Check cache first
        if let cachedImage = await cache.image(for: url) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        // Not in cache, load from network
        phase = .loading
        do {
            let uiImage = try await imageLoader(url)
            // Store in cache
            await cache.setImage(uiImage, for: url)
            phase = .success(Image(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}

// MARK: - AsyncImagePhase

public enum AsyncImagePhase {
    case loading
    case success(Image)
    case failure(Error)
}

// MARK: - Initializer

extension RewardAsyncImage {
    /// Creates an async image with custom content, placeholder, and error views
    public init(
        url: URL?,
        imageLoader: @escaping (URL) async throws -> UIImage,
        cache: ImageCache = .shared,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder error: @escaping (Error) -> ErrorView
    ) {
        self.url = url
        self.imageLoader = imageLoader
        self.cache = cache
        self.content = content
        self.placeholder = placeholder
        self.errorView = error
    }
}

