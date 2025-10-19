//
//  ImageLoaderTests.swift
//  DataLayerTests
//
//  Created by Tymoteusz Pasieka on 10/19/25.
//

import Testing
import ComposableArchitecture
import UIKit

@testable import DataLayer

@Suite("ImageLoader Tests")
struct ImageLoaderTests {
    
    // Helper actor to safely track call counts in concurrent contexts
    actor CallCounter {
        private var count = 0
        
        func increment() {
            count += 1
        }
        
        func getCount() -> Int {
            return count
        }
    }
    
    // MARK: - Success Tests
    
    @Test("Successfully loads image on first attempt")
    func loadImageSuccess() async throws {
        let expectedImage = UIImage(systemName: "star.fill")!
        let counter = CallCounter()
        
        try await withDependencies {
            $0.imageLoader.loadImage = { url in
                await counter.increment()
                return expectedImage
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            let url = URL(string: "https://example.com/image.jpg")!
            let result = try await imageLoader.loadImage(url)
            
            #expect(result === expectedImage)
            let count = await counter.getCount()
            #expect(count == 1, "Should only call once on success")
        }
    }
    
    // MARK: - Retry Tests
    
    @Test("Retries once and succeeds on second attempt")
    func retryOnceAndSucceed() async throws {
        let expectedImage = UIImage(systemName: "star.fill")!
        let counter = CallCounter()
        
        // Mock the live implementation with retry logic
        try await withDependencies {
            $0.imageLoader.loadImage = { url in
                try await Self.loadImageWithRetry(
                    url: url,
                    maxAttempts: 3,
                    mockImplementation: { _ in
                        await counter.increment()
                        let count = await counter.getCount()
                        if count == 1 {
                            throw URLError(.networkConnectionLost)
                        }
                        return expectedImage
                    }
                )
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            let url = URL(string: "https://example.com/image.jpg")!
            let result = try await imageLoader.loadImage(url)
            
            #expect(result === expectedImage)
            let count = await counter.getCount()
            #expect(count == 2, "Should retry once after first failure")
        }
    }
    
    // Helper to simulate retry logic in tests
    private static func loadImageWithRetry(
        url: URL,
        maxAttempts: Int,
        currentAttempt: Int = 1,
        mockImplementation: (URL) async throws -> UIImage
    ) async throws -> UIImage {
        do {
            return try await mockImplementation(url)
        } catch {
            if currentAttempt < maxAttempts {
                let delay = Double(currentAttempt - 1) * 0.5
                if delay > 0 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
                return try await loadImageWithRetry(
                    url: url,
                    maxAttempts: maxAttempts,
                    currentAttempt: currentAttempt + 1,
                    mockImplementation: mockImplementation
                )
            }
            throw error
        }
    }
    
    @Test("Retries twice and succeeds on third attempt")
    func retryTwiceAndSucceed() async throws {
        let expectedImage = UIImage(systemName: "star.fill")!
        let counter = CallCounter()
        
        try await withDependencies {
            $0.imageLoader.loadImage = { url in
                try await Self.loadImageWithRetry(
                    url: url,
                    maxAttempts: 3,
                    mockImplementation: { _ in
                        await counter.increment()
                        let count = await counter.getCount()
                        if count <= 2 {
                            throw URLError(.networkConnectionLost)
                        }
                        return expectedImage
                    }
                )
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            let url = URL(string: "https://example.com/image.jpg")!
            let result = try await imageLoader.loadImage(url)
            
            #expect(result === expectedImage)
            let count = await counter.getCount()
            #expect(count == 3, "Should retry twice before success")
        }
    }
    
    @Test("Fails after maximum retry attempts")
    func failsAfterMaxRetries() async throws {
        let counter = CallCounter()
        let expectedError = URLError(.networkConnectionLost)
        
        await withDependencies {
            $0.imageLoader.loadImage = { url in
                try await Self.loadImageWithRetry(
                    url: url,
                    maxAttempts: 3,
                    mockImplementation: { _ in
                        await counter.increment()
                        throw expectedError
                    }
                )
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            let url = URL(string: "https://example.com/image.jpg")!
            
            do {
                _ = try await imageLoader.loadImage(url)
                Issue.record("Expected error to be thrown")
            } catch is URLError {
                // Expected error type
            } catch {
                Issue.record("Expected URLError but got \(error)")
            }
            
            let count = await counter.getCount()
            #expect(count == 3, "Should attempt 3 times before giving up")
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Preserves error type through retries")
    func preservesErrorType() async throws {
        let counter = CallCounter()
        
        struct CustomError: Error, Equatable {
            let message: String
        }
        
        let expectedError = CustomError(message: "Image not found")
        
        await withDependencies {
            $0.imageLoader.loadImage = { url in
                try await Self.loadImageWithRetry(
                    url: url,
                    maxAttempts: 3,
                    mockImplementation: { _ in
                        await counter.increment()
                        throw expectedError
                    }
                )
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            let url = URL(string: "https://example.com/image.jpg")!
            
            do {
                _ = try await imageLoader.loadImage(url)
                Issue.record("Should have thrown error")
            } catch let error as CustomError {
                #expect(error == expectedError)
            } catch {
                Issue.record("Wrong error type thrown")
            }
            
            let count = await counter.getCount()
            #expect(count == 3)
        }
    }
    
    // MARK: - URL Tests
    
    @Test("Passes correct URL to load function")
    func passesCorrectURL() async throws {
        let expectedImage = UIImage(systemName: "star.fill")!
        let expectedURL = URL(string: "https://example.com/special-image.jpg")!
        
        actor URLCollector {
            private var urls: [URL] = []
            
            func add(_ url: URL) {
                urls.append(url)
            }
            
            func getURLs() -> [URL] {
                return urls
            }
        }
        
        let collector = URLCollector()
        
        try await withDependencies {
            $0.imageLoader.loadImage = { url in
                await collector.add(url)
                return expectedImage
            }
        } operation: {
            @Dependency(\.imageLoader) var imageLoader
            
            _ = try await imageLoader.loadImage(expectedURL)
            
            let receivedURLs = await collector.getURLs()
            #expect(receivedURLs.count == 1)
            #expect(receivedURLs[0] == expectedURL)
        }
    }
}

