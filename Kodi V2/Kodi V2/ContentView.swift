import SwiftUI


struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @State private var isDraggingSlider = false
    @State private var timer: Timer? = nil
    
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
                HStack {
                    Text(formatTime(kodiClient.playbackPosition))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formatTime(kodiClient.totalDuration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                
                Slider(
                    value: $kodiClient.playbackPosition,
                    in: 0...kodiClient.totalDuration,
                    step: 1.0,
                    onEditingChanged: { editing in
                        kodiClient.isSeeking = editing
                        if !editing {
                            // User finished seeking, update Kodi playback position
                            kodiClient.setKodiPlaybackPosition(kodiClient.playbackPosition)
                        }
                    }
                )
                .tint(.blue)
                .padding(.horizontal, 20)
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            
            // Playback Controls with Stop Button
            HStack(spacing: 20) {
                ControlButton(imageName: "backward.fill", action: { kodiClient.rewind() })
                ControlButton(imageName: "playpause.fill", action: { kodiClient.togglePlayPause() })
                ControlButton(imageName: "stop.fill", action: { kodiClient.stopPlayback() })
                ControlButton(imageName: "forward.fill", action: { kodiClient.fastForward() })
            }
        }
        .padding()
        .background(Color(.systemGray6).ignoresSafeArea())
        .onAppear {
            kodiClient.fetchPlaybackInfo()
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            kodiClient.fetchPlaybackInfo()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
                .frame(width: 70, height: 70)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

#Preview {
    ContentView()
}
