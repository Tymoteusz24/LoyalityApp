//
//  ImageCache.swift
//  AppWrapper
//
//  Created by Tymoteusz Pasieka on 11/18/25.
//

import UIKit

protocol ImageCacheProtocol: Actor {
    func image(for url: URL) -> UIImage?
    func setImage(_ image: UIImage, for url: URL)
    func removeImage(for url: URL)
    func clear()
}

/// Thread-safe image cache using NSCache
public actor ImageCache: ImageCacheProtocol {
    public static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    /// Retrieves an image from the cache
    public func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }
    
    /// Stores an image in the cache
    public func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    /// Removes an image from the cache
    public func removeImage(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }
    
    /// Clears all cached images
    public func clear() {
        cache.removeAllObjects()
    }
}

