import SwiftUI

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @State private var isDraggingSlider = false
    @State private var timer: Timer? = nil
    @State private var isShowingSettings = false
    @State private var showVolumeControls = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            // Background image with caching
            if let thumbnail = kodiClient.currentThumbnail,
               !kodiClient.kodiAddress.isEmpty,
               let thumbnailURL = URL(string: "http://\(kodiClient.kodiAddress):\(kodiClient.port)/image/\(thumbnail.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                        .overlay(
                            Color.black.opacity(0.5)
                        )
                } placeholder: {
                    Color(.systemGray6).ignoresSafeArea()
                }
            } else {
                Color(.systemGray6).ignoresSafeArea()
            }

            // Foreground content
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 10)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(kodiClient.currentMovieTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Connection status indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(kodiClient.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(kodiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            performHaptic(.light)
                            isShowingSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            performHaptic(.light)
                            showVolumeControls.toggle()
                        }) {
                            Image(systemName: showVolumeControls ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(showVolumeControls ? Color.blue.opacity(0.7) : Color.gray.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
                
                // Volume controls (conditional)
                if showVolumeControls {
                    HStack(spacing: 20) {
                        ControlButton(imageName: "speaker.fill", action: {
                            performHaptic(.medium)
                            kodiClient.toggleMute()
                        }, size: 50)
                        ControlButton(imageName: "minus", action: {
                            performHaptic(.light)
                            kodiClient.volumeDown()
                        }, size: 50)
                        ControlButton(imageName: "plus", action: {
                            performHaptic(.light)
                            kodiClient.volumeUp()
                        }, size: 50)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack(spacing: 20) {
                    ControlButton(imageName: "chevron.up", action: {
                        performHaptic(.light)
                        kodiClient.sendDirection(.up)
                    })

                    HStack(spacing: 40) {
                        ControlButton(imageName: "chevron.left", action: {
                            performHaptic(.light)
                            kodiClient.sendDirection(.left)
                        })

                        Button(action: {
                            performHaptic(.medium)
                            kodiClient.sendSelectAction()
                        }) {
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

                        ControlButton(imageName: "chevron.right", action: {
                            performHaptic(.light)
                            kodiClient.sendDirection(.right)
                        })
                    }

                    ControlButton(imageName: "chevron.down", action: {
                        performHaptic(.light)
                        kodiClient.sendDirection(.down)
                    })
                }
                
                // Navigation buttons (Back, Home)
                HStack(spacing: 20) {
                    ControlButton(imageName: "chevron.backward", action: {
                        performHaptic(.medium)
                        kodiClient.sendInputAction(.back)
                    }, size: 50)
                    ControlButton(imageName: "house.fill", action: {
                        performHaptic(.medium)
                        kodiClient.sendInputAction(.home)
                    }, size: 50)
                    ControlButton(imageName: "list.bullet", action: {
                        performHaptic(.medium)
                        kodiClient.sendInputAction(.contextMenu)
                    }, size: 50)
                }

                Spacer()

                VStack(spacing: 10) {
                    if kodiClient.isLoading {
                        HStack {
                            ProgressView()
                                .tint(.white)
                            Text("Loading...")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                    } else if kodiClient.totalDuration > 0 {
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
                                isDraggingSlider = editing
                                if !editing {
                                    performHaptic(.light)
                                    kodiClient.setKodiPlaybackPosition(kodiClient.playbackPosition)
                                }
                            }
                        )
                        .tint(.blue)
                        .padding(.horizontal, 20)
                    } else if kodiClient.kodiAddress.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "network.slash")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No server configured")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Button(action: {
                                isShowingSettings = true
                            }) {
                                Text("Configure Server")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "play.slash")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No active playback")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }

                HStack(spacing: 20) {
                    ControlButton(imageName: "backward.fill", action: {
                        performHaptic(.medium)
                        kodiClient.rewind()
                    })
                    ControlButton(imageName: "playpause.fill", action: {
                        performHaptic(.medium)
                        kodiClient.togglePlayPause()
                    })
                    ControlButton(imageName: "stop.fill", action: {
                        performHaptic(.heavy)
                        kodiClient.stopPlayback()
                    })
                    ControlButton(imageName: "forward.fill", action: {
                        performHaptic(.medium)
                        kodiClient.fastForward()
                    })
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(kodiClient: kodiClient) // Present SettingsView
            }
        }
        .onAppear {
            kodiClient.fetchPlaybackInfo()
        }
        .alert(isPresented: $kodiClient.showErrorAlert) {
            Alert(
                title: Text("Connection Error"),
                message: Text(kodiClient.errorMessage + "\n\nPlease check your server settings."),
                primaryButton: .default(Text("Settings")) {
                    isShowingSettings = true
                },
                secondaryButton: .cancel(Text("Dismiss"))
            )
        }
        .animation(.spring(), value: showVolumeControls)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // Resume polling when app becomes active
                startTimer()
            case .background, .inactive:
                // Stop polling to save battery when app goes to background
                stopTimer()
            @unknown default:
                break
            }
        }
    }

    func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    func performHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func startTimer() {
        // Stop existing timer if any
        stopTimer()
        
        // Optimized polling: 2 seconds instead of 1 second
        // This reduces battery usage by 50% while maintaining responsiveness
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            guard !isDraggingSlider else { return }
            kodiClient.fetchPlaybackInfo()
        }
        
        // Add to run loop to ensure it fires even during scrolling
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


struct ControlButton: View {
    let imageName: String
    let action: () -> Void
    var size: CGFloat = 70
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(size < 60 ? .title2 : .title)
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

#Preview {
    ContentView()
}
