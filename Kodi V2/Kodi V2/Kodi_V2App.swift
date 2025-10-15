//
//  Kodi_V2App.swift
//  Kodi V2
//
//  Created by Toni Nichev on 11/12/24.
//

import SwiftUI

@main
struct Kodi_V2App: App {
    
    init() {
        // Configure URLCache for better network caching
        let memoryCapacity = 50 * 1024 * 1024  // 50 MB memory cache
        let diskCapacity = 100 * 1024 * 1024   // 100 MB disk cache
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        URLCache.shared = urlCache
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
