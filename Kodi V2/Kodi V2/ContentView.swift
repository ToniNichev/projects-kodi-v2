import SwiftUI

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Light background for a modern, clean look

            VStack {
                // Top - Up Button and Info
                HStack {
                    Spacer()
                    Button(action: {
                        kodiClient.showInfo()
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }

                Spacer()

                // Up Button
                Button(action: {
                    kodiClient.navigate(direction: "Up")
                }) {
                    Image(systemName: "chevron.up.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 30)

                // Center Row - Left, OK, Right
                HStack {
                    // Left button
                    Button(action: {
                        kodiClient.navigate(direction: "Left")
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // OK button in the center
                    Button(action: {
                        kodiClient.sendRequest(method: "Input.Select") { result in
                            printResult(result, action: "OK")
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Right button
                    Button(action: {
                        kodiClient.navigate(direction: "Right")
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                // Down Button
                Button(action: {
                    kodiClient.navigate(direction: "Down")
                }) {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 50)

                Spacer()

                // Bottom - Media Controls (Back, Play, Pause, Stop)
                HStack(spacing: 40) {
                    // Back button
                    Button(action: {
                        kodiClient.back()
                    }) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }

                    // Play button
                    Button(action: {
                        kodiClient.sendRequest(method: "Player.PlayPause", params: ["playerid": 1]) { result in
                            printResult(result, action: "Play")
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }

                    // Pause button
                    Button(action: {
                        kodiClient.sendRequest(method: "Player.PlayPause", params: ["playerid": 1]) { result in
                            printResult(result, action: "Pause")
                        }
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }

                    // Stop button
                    Button(action: {
                        kodiClient.stop()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    private func printResult(_ result: Result<Data, Error>, action: String) {
        switch result {
        case .success:
            print("\(action) Success")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
