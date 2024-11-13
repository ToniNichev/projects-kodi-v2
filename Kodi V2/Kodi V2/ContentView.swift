import SwiftUI

struct ContentView: View {
    @StateObject private var kodiClient = KodiClient()

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
                }
                
                Spacer()

                // Up Button
                Button(action: {
                    kodiClient.navigate(direction: "Up")
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
                        kodiClient.navigate(direction: "Left")
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // OK button in the center
                    Button(action: {
                        kodiClient.sendRequest(method: "Input.Select") { result in
                            printResult(result, action: "OK")
                        }
                    }) {
                        Image(systemName: "circle")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Right button
                    Button(action: {
                        kodiClient.navigate(direction: "Right")
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
                    kodiClient.navigate(direction: "Down")
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                Spacer()

                // Bottom - Media Controls (Back, Play, Pause, Stop)
                HStack(spacing: 30) {
                    // Back button
                    Button(action: {
                        kodiClient.back()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Play button
                    Button(action: {
                        kodiClient.sendRequest(method: "Player.PlayPause", params: ["playerid": 1]) { result in
                            printResult(result, action: "Play")
                        }
                    }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }

                    // Pause button
                    Button(action: {
                        kodiClient.sendRequest(method: "Player.PlayPause", params: ["playerid": 1]) { result in
                            printResult(result, action: "Pause")
                        }
                    }) {
                        Image(systemName: "pause.fill")
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
            .padding(.horizontal, 20)
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
