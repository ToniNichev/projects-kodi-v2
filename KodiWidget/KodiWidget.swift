//
//  KodiWidget.swift
//  KodiWidget
//
//  Widget for Kodi Remote V2
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), playbackData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let playbackData = SharedDataManager.shared.loadPlaybackData()
        let entry = SimpleEntry(date: Date(), playbackData: playbackData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let playbackData = SharedDataManager.shared.loadPlaybackData()
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, playbackData: playbackData)
        
        // Update every 30 seconds
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let playbackData: PlaybackData?
}

struct KodiWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        if let playback = entry.playbackData {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                // Title
                Text(playback.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Spacer()
                
                // Progress
                VStack(alignment: .leading, spacing: 4) {
                    ProgressView(value: playback.currentTime, total: playback.totalTime)
                        .tint(.blue)
                    
                    Text(playback.formattedCurrentTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        } else {
            // No playback
            VStack {
                Image(systemName: "play.slash")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text("No Playback")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        if let playback = entry.playbackData {
            HStack(spacing: 12) {
                // Thumbnail or placeholder
                if let urlString = playback.thumbnailURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "film")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(playback.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    // Metadata
                    if let year = playback.year, let genre = playback.genre {
                        Text("\(year) • \(genre)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else if let year = playback.year {
                        Text(String(year))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let genre = playback.genre {
                        Text(genre)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: playback.currentTime, total: playback.totalTime)
                            .tint(.blue)
                        
                        HStack {
                            Text(playback.formattedCurrentTime)
                            Spacer()
                            Text(playback.formattedTotalTime)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        } else {
            // No playback
            HStack {
                Image(systemName: "play.slash")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                VStack(alignment: .leading) {
                    Text("No Active Playback")
                        .font(.headline)
                    Text("Play media on Kodi to see it here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let entry: Provider.Entry
    
    var body: some View {
        if let playback = entry.playbackData {
            VStack(spacing: 12) {
                // Thumbnail
                if let urlString = playback.thumbnailURL,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "film")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 180)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "film")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(playback.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    // Metadata
                    HStack(spacing: 8) {
                        if let year = playback.year {
                            Label(String(year), systemImage: "calendar")
                                .font(.subheadline)
                        }
                        if playback.year != nil && playback.genre != nil {
                            Text("•")
                                .foregroundColor(.secondary)
                        }
                        if let genre = playback.genre {
                            Label(genre, systemImage: "film")
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: playback.currentTime, total: playback.totalTime)
                            .tint(.blue)
                        
                        HStack {
                            Text(playback.formattedCurrentTime)
                            Spacer()
                            Text("\(Int(playback.progressPercentage))%")
                            Spacer()
                            Text(playback.formattedTotalTime)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        } else {
            // No playback
            VStack(spacing: 16) {
                Image(systemName: "play.slash")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                VStack(spacing: 8) {
                    Text("No Active Playback")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Play media on your Kodi server to see playback information here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

@main
struct KodiWidget: Widget {
    let kind: String = "KodiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KodiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kodi Playback")
        .description("View current playback from your Kodi media center")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct KodiWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = PlaybackData(
            title: "The Dark Knight",
            year: 2008,
            genre: "Action, Crime",
            currentTime: 3600,
            totalTime: 9000,
            isPlaying: true,
            thumbnailURL: nil,
            lastUpdated: Date()
        )
        
        Group {
            KodiWidgetEntryView(entry: SimpleEntry(date: Date(), playbackData: sampleData))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            KodiWidgetEntryView(entry: SimpleEntry(date: Date(), playbackData: sampleData))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            KodiWidgetEntryView(entry: SimpleEntry(date: Date(), playbackData: sampleData))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

