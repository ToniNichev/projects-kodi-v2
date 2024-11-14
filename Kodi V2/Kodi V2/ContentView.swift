import SwiftUI
import Foundation

// Wrapper struct for error message, conforming to Identifiable
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Kodi Remote Control SwiftUI App

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @State private var isPlaying = false // State variable to track play/pause
    @State private var errorMessage: ErrorMessage? // State for error message
    @State private var showHelpAlert = false // State for showing help alert

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Plain white background for a minimal look

            VStack {
                // Top Info Button
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

                // Up Button
                Button(action: {
                    kodiClient.navigate(direction: .up)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)

                // Center Row - Left, OK, Right
                HStack {
                    // Left button
                    Button(action: {
                        kodiClient.navigate(direction: .left)
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // OK button in the center
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

                    // Right button
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

                // Down Button
                Button(action: {
                    kodiClient.navigate(direction: .down)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                Spacer()

                // Bottom - Media Controls (Back, Play, Pause, Stop, Fast Forward, Rewind)
                HStack(spacing: 30) {
                    // Back button
                    Button(action: {
                        kodiClient.back()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Rewind button
                    Button(action: {
                        kodiClient.rewind()
                    }) {
                        Image(systemName: "gobackward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Play/Pause button that toggles icon based on play state
                    Button(action: {
                        kodiClient.playPause()
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Fast Forward button
                    Button(action: {
                        kodiClient.fastForward()
                    }) {
                        Image(systemName: "goforward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Stop button
                    Button(action: {
                        kodiClient.stop()
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 120)
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .sendRequestFailed, object: nil, queue: .main) { notification in
                self.showHelpAlert = true
            }
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
}

#Preview {
    ContentView()
}
