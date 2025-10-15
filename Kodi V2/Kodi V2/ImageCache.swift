//
//  ImageCache.swift
//  Kodi V2
//
//  Image caching manager for Kodi thumbnails
//

import UIKit
import SwiftUI

/// Manages in-memory and disk caching of images
class ImageCache {
    static let shared = ImageCache()
    
    // In-memory cache
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // Disk cache directory
    private let diskCacheURL: URL
    
    // Maximum cache size (50 MB)
    private let maxDiskCacheSize: Int64 = 50 * 1024 * 1024
    
    private init() {
        // Set up memory cache
        memoryCache.countLimit = 100 // Max 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
        
        // Set up disk cache directory
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDirectory.appendingPathComponent("KodiThumbnails")
        
        // Create cache directory if it doesn't exist
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // Clean old cache on init
        cleanExpiredCache()
    }
    
    // MARK: - Public Methods
    
    /// Get image from cache (memory first, then disk)
    func getImage(forKey key: String) -> UIImage? {
        let cacheKey = key as NSString
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        if let diskImage = loadImageFromDisk(forKey: key) {
            // Store in memory cache for next time
            memoryCache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }
        
        return nil
    }
    
    /// Save image to cache (both memory and disk)
    func setImage(_ image: UIImage, forKey key: String) {
        let cacheKey = key as NSString
        
        // Save to memory cache
        memoryCache.setObject(image, forKey: cacheKey)
        
        // Save to disk cache
        saveImageToDisk(image, forKey: key)
    }
    
    /// Clear all cached images
    func clearCache() {
        memoryCache.removeAllObjects()
        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    
    private func diskCacheURL(forKey key: String) -> URL {
        let hashedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return diskCacheURL.appendingPathComponent(hashedKey)
    }
    
    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = diskCacheURL(forKey: key)
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = diskCacheURL(forKey: key)
        try? data.write(to: fileURL)
    }
    
    private func cleanExpiredCache() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let fileManager = FileManager.default
            guard let files = try? fileManager.contentsOfDirectory(
                at: self.diskCacheURL,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
            ) else { return }
            
            // Get total cache size
            var totalSize: Int64 = 0
            var fileInfo: [(url: URL, date: Date, size: Int64)] = []
            
            for fileURL in files {
                if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                   let size = attributes[.size] as? Int64,
                   let modDate = attributes[.modificationDate] as? Date {
                    totalSize += size
                    fileInfo.append((url: fileURL, date: modDate, size: size))
                }
            }
            
            // If cache is too large, remove oldest files
            if totalSize > self.maxDiskCacheSize {
                // Sort by date (oldest first)
                fileInfo.sort { $0.date < $1.date }
                
                var currentSize = totalSize
                for file in fileInfo {
                    if currentSize <= self.maxDiskCacheSize {
                        break
                    }
                    try? fileManager.removeItem(at: file.url)
                    currentSize -= file.size
                }
            }
            
            // Remove files older than 7 days
            let expirationDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            for file in fileInfo {
                if file.date < expirationDate {
                    try? fileManager.removeItem(at: file.url)
                }
            }
        }
    }
}

/// Image loader for async loading with caching
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private var url: URL?
    private var task: URLSessionDataTask?
    
    func load(url: URL) {
        // Don't reload if already loading the same URL
        guard self.url != url else { return }
        self.url = url
        
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        isLoading = true
        task?.cancel()
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data, let loadedImage = UIImage(data: data) {
                    self.image = loadedImage
                    // Cache the image
                    ImageCache.shared.setImage(loadedImage, forKey: cacheKey)
                }
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
}

