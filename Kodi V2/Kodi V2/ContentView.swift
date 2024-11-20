import SwiftUI


struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()
    @StateObject private var colorSchemeSettings = ColorSchemeSettings()
    @State private var isDraggingSlider = false
    @State private var timer: Timer? = nil
    @State private var isShowingSettings = false
    @State private var isShowingColorPicker = false // State for showing color picker

    var body: some View {
        ZStack {
            // Background image
            if let thumbnail = kodiClient.currentThumbnail,
               let thumbnailURL = URL(string: "http://10.0.1.119:8080/image/\(thumbnail.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")") {
                AsyncImage(url: thumbnailURL) { image in
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
                    Text(kodiClient.currentMovieTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    Spacer()
                    Button(action: {
                        isShowingSettings.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 20) {
                    ControlButton(
                        imageName: "chevron.up",
                        action: { kodiClient.sendDirection(.up) },
                        buttonColor: colorSchemeSettings.buttonColor
                    )

                    HStack(spacing: 40) {
                        ControlButton(
                            imageName: "chevron.left",
                            action: { kodiClient.sendDirection(.left) },
                            buttonColor: colorSchemeSettings.buttonColor
                        )

                        Button(action: { kodiClient.sendSelectAction() }) {
                            Circle()
                                .fill(colorSchemeSettings.buttonColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("OK")
                                        .font(.headline)
                                        .foregroundColor(colorSchemeSettings.buttonColor)
                                )
                                .shadow(radius: 5)
                        }

                        ControlButton(
                            imageName: "chevron.right",
                            action: { kodiClient.sendDirection(.right) },
                            buttonColor: colorSchemeSettings.buttonColor
                        )
                    }

                    ControlButton(
                        imageName: "chevron.down",
                        action: { kodiClient.sendDirection(.down) },
                        buttonColor: colorSchemeSettings.buttonColor
                    )
                }

                Spacer()

                VStack(spacing: 10) {
                    if kodiClient.totalDuration > 0 {
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
                                    kodiClient.setKodiPlaybackPosition(kodiClient.playbackPosition)
                                }
                            }
                        )
                        .tint(colorSchemeSettings.buttonColor)
                        .padding(.horizontal, 20)
                    } else {
                        Text("No playback information available")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                    ControlButton(
                        imageName: "backward.fill",
                        action: { kodiClient.rewind() },
                        buttonColor: colorSchemeSettings.buttonColor
                    )
                    ControlButton(
                        imageName: "playpause.fill",
                        action: { kodiClient.togglePlayPause() },
                        buttonColor: colorSchemeSettings.buttonColor
                    )
                    ControlButton(
                        imageName: "stop.fill",
                        action: { kodiClient.stopPlayback() },
                        buttonColor: colorSchemeSettings.buttonColor
                    )
                    ControlButton(
                        imageName: "forward.fill",
                        action: { kodiClient.fastForward() },
                        buttonColor: colorSchemeSettings.buttonColor
                    )
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(kodiClient: kodiClient, colorSchemeSettings: colorSchemeSettings)
            }
            .sheet(isPresented: $isShowingColorPicker) {
                VStack {
                    Text("Select Button Color")
                        .font(.headline)
                        .padding()

                    ColorPicker("Button Color", selection: $colorSchemeSettings.buttonColor)
                        .padding()
                        .frame(maxWidth: 300)

                    Button("Close") {
                        isShowingColorPicker = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShowingColorPicker.toggle() }) {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.white)
                }
            }
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
            guard !isDraggingSlider else { return }
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
    let buttonColor: Color
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(buttonColor)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

#Preview {
    ContentView()
}
