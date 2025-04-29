//
//  OptimizedAsyncImage.swift
//  Cavacham
//
//  Created by Govind Pathak on 27/04/25.
//

import SwiftUI

struct OptimizedAsyncImage<Content: View>: View {
    private let url: URL?
    private let imageCache: NSCache<NSString, UIImage>?
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL?, imageCache: NSCache<NSString, UIImage>? = nil, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.imageCache = imageCache
        self.content = content
    }
    
    var body: some View {
        if let imageCache = imageCache, let url = url {
            CachedAsyncImage(url: url, cache: imageCache, content: content)
        } else {
            AsyncImage(url: url, content: content)
        }
    }
}

private struct CachedAsyncImage<Content: View>: View {
    private let url: URL
    private let cache: NSCache<NSString, UIImage>
    private let content: (AsyncImagePhase) -> Content
    @State private var phase: AsyncImagePhase = .empty
    
    init(url: URL, cache: NSCache<NSString, UIImage>, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.cache = cache
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        let urlString = url.absoluteString
        
        // Check if image exists in cache
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            self.phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        // Load from URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.phase = .failure(error)
                }
                return
            }
            
            guard let data = data, let loadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.phase = .failure(URLError(.badServerResponse))
                }
                return
            }
            
            // Cache the loaded image
            self.cache.setObject(loadedImage, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.phase = .success(Image(uiImage: loadedImage))
            }
        }.resume()
    }
} 