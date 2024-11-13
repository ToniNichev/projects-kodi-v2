import SwiftUI

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()

    var body: some View {
        VStack(spacing: 20) {
            Text("Kodi Remote")
                .font(.largeTitle)
                .padding()

            // Directional Controls
            VStack {
                Button(action: {
                    kodiClient.navigate(direction: "Up")
                }) {
                    Image(systemName: "chevron.up.circle.fill")
                        .font(.largeTitle)
                }

                HStack {
                    Button(action: {
                        kodiClient.navigate(direction: "Left")
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.largeTitle)
                    }

                    Button(action: {
                        kodiClient.showInfo()
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.largeTitle)
                    }

                    Button(action: {
                        kodiClient.navigate(direction: "Right")
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.largeTitle)
                    }
                }

                Button(action: {
                    kodiClient.navigate(direction: "Down")
                }) {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.largeTitle)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))

            // Media Controls
            HStack(spacing: 30) {
                Button(action: {
                    kodiClient.back()
                }) {
                    Label("Back", systemImage: "arrow.uturn.backward.circle.fill")
                        .font(.title2)
                }

                Button(action: {
                    kodiClient.playPause()
                }) {
                    Label("Play/Pause", systemImage: "playpause.fill")
                        .font(.title2)
                }

                Button(action: {
                    kodiClient.stop()
                }) {
                    Label("Stop", systemImage: "stop.fill")
                        .font(.title2)
                }
            }
            .padding()
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
