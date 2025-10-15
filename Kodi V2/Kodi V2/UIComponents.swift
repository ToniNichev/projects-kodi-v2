//
//  UIComponents.swift
//  Kodi V2
//
//  Reusable UI components with glassmorphism and modern design
//

import SwiftUI

// MARK: - Glassmorphism Card
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
    }
}

// MARK: - Modern Control Button
struct ModernControlButton: View {
    let imageName: String
    let action: () -> Void
    var size: CGFloat = 70
    var color: Color = .blue
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                // Background gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                // Icon
                Image(systemName: imageName)
                    .font(size < 60 ? .title2 : .title)
                    .foregroundColor(.white)
            }
            .shadow(color: color.opacity(0.4), radius: isPressed ? 5 : 10, x: 0, y: isPressed ? 2 : 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Info Badge
struct InfoBadge: View {
    let icon: String
    let text: String
    var color: Color = .white
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Progress Card
struct ProgressCard: View {
    let currentTime: String
    let totalTime: String
    let progress: Double
    let total: Double
    let onSeek: (Double) -> Void
    
    @Binding var isDragging: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Time labels
            HStack {
                Text(currentTime)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text(totalTime)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Progress slider
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 6)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, CGFloat((progress / total)) * (UIScreen.main.bounds.width - 80)), height: 6)
                
                // Custom slider overlay
                GeometryReader { geometry in
                    Slider(
                        value: Binding(
                            get: { progress },
                            set: { onSeek($0) }
                        ),
                        in: 0...total,
                        step: 1.0,
                        onEditingChanged: { editing in
                            isDragging = editing
                        }
                    )
                    .accentColor(.clear)
                    .opacity(0.05)
                }
                .frame(height: 44)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Connection Status Badge
struct ConnectionBadge: View {
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .shadow(color: (isConnected ? Color.green : Color.red).opacity(0.6), radius: 4, x: 0, y: 0)
            
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Volume Control Panel
struct VolumeControlPanel: View {
    let onMute: () -> Void
    let onVolumeDown: () -> Void
    let onVolumeUp: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ModernControlButton(
                imageName: "speaker.fill",
                action: onMute,
                size: 50,
                color: .purple
            )
            
            ModernControlButton(
                imageName: "minus",
                action: onVolumeDown,
                size: 50,
                color: .orange
            )
            
            ModernControlButton(
                imageName: "plus",
                action: onVolumeUp,
                size: 50,
                color: .orange
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
    }
}

