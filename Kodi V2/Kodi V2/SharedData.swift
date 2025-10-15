//
//  SharedData.swift
//  Kodi V2
//
//  Shared data model for app and widget communication
//

import Foundation

/// App Group identifier for sharing data between app and widget
let appGroupIdentifier = "group.com.kodiremote.v2"

/// Shared playback data structure
struct PlaybackData: Codable {
    let title: String
    let year: Int?
    let genre: String?
    let currentTime: Double
    let totalTime: Double
    let isPlaying: Bool
    let thumbnailURL: String?
    let lastUpdated: Date
    
    var progressPercentage: Double {
        guard totalTime > 0 else { return 0 }
        return (currentTime / totalTime) * 100
    }
    
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}

/// Manager for shared data between app and widget
class SharedDataManager {
    static let shared = SharedDataManager()
    
    private let userDefaults: UserDefaults?
    private let playbackDataKey = "playbackData"
    
    private init() {
        userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - Save/Load Playback Data
    
    func savePlaybackData(_ data: PlaybackData) {
        guard let userDefaults = userDefaults else {
            print("Error: Could not access App Group UserDefaults")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(data)
            userDefaults.set(encoded, forKey: playbackDataKey)
            userDefaults.synchronize()
            
            // Trigger widget reload
            #if os(iOS)
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            #endif
        } catch {
            print("Error encoding playback data: \(error)")
        }
    }
    
    func loadPlaybackData() -> PlaybackData? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: playbackDataKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PlaybackData.self, from: data)
        } catch {
            print("Error decoding playback data: \(error)")
            return nil
        }
    }
    
    func clearPlaybackData() {
        userDefaults?.removeObject(forKey: playbackDataKey)
        userDefaults?.synchronize()
        
        #if os(iOS)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
}

#if os(iOS)
import WidgetKit
#endif

