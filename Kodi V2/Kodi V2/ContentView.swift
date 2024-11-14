import SwiftUI

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @State private var isPlaying = false
    @State private var totalDuration: Double = 100.0 // 100 %
    @State private var playbackPosition: Double = 0.0
    @State private var errorMessage: ErrorMessage?
    @State private var showHelpAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        kodiClient.showInfo()
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .padding()
                    }
                    Button("Settings") {
                        // Placeholder for settings UI
                    }
                }
                
                Spacer()

                // Navigation Controls
                Button(action: {
                    kodiClient.navigate(direction: .up)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)

                HStack {
                    Button(action: {
                        kodiClient.navigate(direction: .left)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: {
                        kodiClient.sendRequest(method: "Input.Select") { result in
                            self.printResult(result, action: "OK")
                        }
                    }) {
                        Image(systemName: "circle")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: {
                        kodiClient.navigate(direction: .right)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

                Button(action: {
                    kodiClient.navigate(direction: .down)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                Spacer()
                
                // Playback Control Buttons
                HStack(spacing: 30) {
                    Button(action: {
                        kodiClient.back()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        kodiClient.rewind()
                    }) {
                        Image(systemName: "gobackward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        kodiClient.playPause()
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        kodiClient.fastForward()
                    }) {
                        Image(systemName: "goforward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        kodiClient.stop()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 20)
                
                // Slider for Seeking
                VStack {
                    Slider(value: $playbackPosition, in: 0...totalDuration, step: 1.0) {
                        Text("Position")
                    } minimumValueLabel: {
                        Text("0:00")
                    } maximumValueLabel: {
                        Text(formatTime(totalDuration))
                    }
                    .onChange(of: playbackPosition) { newValue in
                        kodiClient.setKodiPlaybackPosition(newValue)
                    }
                    
                    Text("Playback Position: \(formatTime(playbackPosition))")
                        .padding()
                }
                .padding(.bottom, 40)
                .onAppear()
                {
                    kodiClient.fetchPlaybackInfo()
                }
            }
            .padding(.horizontal, 120)
        }
        .alert("Error", isPresented: $showHelpAlert) {
            Button("Visit Help Page") {
                if let url = URL(string: "https://kodi.com/how-to") {
                    UIApplication.shared.open(url)
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("An error occurred while connecting to Kodi. Check your network settings or visit the help page.")
        }
    }

    private func printResult(_ result: Result<Data, Error>, action: String) {
        switch result {
        case .success:
            print("\(action) Success")
        case .failure(let error):
            errorMessage = ErrorMessage(message: "\(action) Error: \(error.localizedDescription)")
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

#Preview {
    ContentView()
}


#Preview {
    ContentView()
}
