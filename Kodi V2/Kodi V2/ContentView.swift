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
            if let thumbnailURL = kodiClient.getThumbnailURL() {
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
                    VStack(alignment: .leading, spacing: 5) {
                        Text(kodiClient.currentMovieTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(kodiClient.currentMovieLabel)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7)) // Slightly dimmer text for the label
                    }
                    .padding(.top, 40)

                    Spacer()

                    ControlButton(
                        imageName: "gearshape.fill",
                        action: { isShowingSettings.toggle() },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 20) {
                    ControlButton(
                        imageName: "chevron.up",
                        action: { kodiClient.sendDirection(.up) },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )

                    HStack(spacing: 40) {
                        ControlButton(
                            imageName: "chevron.left",
                            action: { kodiClient.sendDirection(.left) },
                            buttonColor: colorSchemeSettings.buttonColor,
                            buttonShape: colorSchemeSettings.buttonShape,
                            buttonSize: colorSchemeSettings.buttonSize
                        )

                        Button(action: { kodiClient.sendSelectAction() }) {
                            Circle()
                                .fill(colorSchemeSettings.buttonColor)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text("OK")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                )
                                .shadow(radius: 5)
                        }

                        ControlButton(
                            imageName: "chevron.right",
                            action: { kodiClient.sendDirection(.right) },
                            buttonColor: colorSchemeSettings.buttonColor,
                            buttonShape: colorSchemeSettings.buttonShape,
                            buttonSize: colorSchemeSettings.buttonSize
                        )
                    }

                    ControlButton(
                        imageName: "chevron.down",
                        action: { kodiClient.sendDirection(.down) },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
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
                
                // Volume Control
                VStack {
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.gray)
                        Slider(
                            value: Binding(
                                get: { Double(kodiClient.currentVolume) },
                                set: { newValue in
                                    kodiClient.currentVolume = Int(newValue)
                                    kodiClient.setVolume(Int(newValue))
                                }
                            ),
                            in: 0...100,
                            step: 1.0
                        )
                        .tint(colorSchemeSettings.buttonColor)
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                }

                HStack(spacing: 20) {
                    ControlButton(
                        imageName: "backward.fill",
                        action: { kodiClient.rewind() },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )
                    ControlButton(
                        imageName: "playpause.fill",
                        action: { kodiClient.togglePlayPause() },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )
                    ControlButton(
                        imageName: "stop.fill",
                        action: { kodiClient.stopPlayback() },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )
                    ControlButton(
                        imageName: "forward.fill",
                        action: { kodiClient.fastForward() },
                        buttonColor: colorSchemeSettings.buttonColor,
                        buttonShape: colorSchemeSettings.buttonShape,
                        buttonSize: colorSchemeSettings.buttonSize
                    )
                }
                .padding(.bottom, 20)
                
            }
            .padding(.horizontal)
            .padding(.bottom, 40) // Increased bottom padding
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
            kodiClient.fetchVolume()
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
    let buttonShape: String
    let buttonSize: CGFloat
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(buttonColor)
                .clipShape(getShape())
                .shadow(radius: 5)
        }
    }
    
    func getShape() -> AnyShape {
        switch buttonShape {
        case "Circle":
            return AnyShape(Circle())
        case "Rectangle":
            return AnyShape(RoundedRectangle(cornerRadius: 10))
        case "Capsule":
            return AnyShape(Capsule())
        default:
            return AnyShape(Circle())
        }
    }
}

struct AnyShape: Shape {
    private let path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        self.path = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        path(rect)
    }
}

#Preview {
    ContentView()
}
