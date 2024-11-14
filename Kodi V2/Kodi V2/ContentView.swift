import SwiftUI


struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @State private var playbackPosition: Double = 0.0
    @State private var totalDuration: Double = 100.0
    @State private var isDraggingSlider = false
    
    var body: some View {
        VStack(spacing: 40) {
                        
            Text("Kodi Remote")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 40)
            
            Spacer()
            
            // Directional Controls
            VStack(spacing: 20) {
                ControlButton(imageName: "chevron.up", action: { kodiClient.sendDirection(.up) })
                
                HStack(spacing: 40) {
                    ControlButton(imageName: "chevron.left", action: { kodiClient.sendDirection(.left) })
                    
                    Button(action: { kodiClient.sendSelectAction() }) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("OK")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            )
                            .shadow(radius: 5)
                    }
                    
                    ControlButton(imageName: "chevron.right", action: { kodiClient.sendDirection(.right) })
                }
                
                ControlButton(imageName: "chevron.down", action: { kodiClient.sendDirection(.down) })
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Slider(
                    value: $playbackPosition,
                    in: 0...totalDuration,
                    step: 1.0,
                    onEditingChanged: { editing in
                        isDraggingSlider = editing
                        if !editing {
                            // Only update the playback position when user stops dragging
                            kodiClient.setKodiPlaybackPosition(playbackPosition)
                        }
                    },
                    minimumValueLabel: Text(formatTime(playbackPosition)),
                    maximumValueLabel: Text(formatTime(totalDuration))
                ) {
                    Text("Position")
                }
                .tint(.blue)
                .padding(.horizontal, 20)
                .onChange(of: kodiClient.playbackPosition) { newPosition in
                    if !isDraggingSlider {
                        playbackPosition = newPosition
                    }
                }
            }
            
            // Playback Controls with Stop Button
            HStack(spacing: 20) {
                ControlButton(imageName: "backward.fill", action: { kodiClient.rewind() })
                ControlButton(imageName: "stop.fill", action: { kodiClient.stopPlayback() })
                ControlButton(imageName: "playpause.fill", action: { kodiClient.togglePlayPause() })
                ControlButton(imageName: "forward.fill", action: { kodiClient.fastForward() })
            }
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            kodiClient.fetchPlaybackInfo()
        }
        .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
            if !isDraggingSlider {
                kodiClient.fetchPlaybackInfo()
                playbackPosition = kodiClient.playbackPosition
                totalDuration = kodiClient.totalDuration
            }
        }
        .alert(isPresented: $kodiClient.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(kodiClient.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

struct ControlButton: View {
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

#Preview {
    ContentView()
}
