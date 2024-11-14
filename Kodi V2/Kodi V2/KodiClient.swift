import Foundation
import SwiftUI


class KodiClient: ObservableObject {
    @Published var kodiIP: String = "192.168.1.207" // Default Kodi IP
    @Published var port: Int = 8080                 // Default port
    private let playerID = 1
    @Published var totalDuration: Int = 0 // Media duration in seconds
    @Published var currentPosition: Int = 0 // Current position in seconds

    enum Direction: String {
        case up = "Up"
        case down = "Down"
        case left = "Left"
        case right = "Right"
    }

    func sendRequest(method: String, params: [String: Any] = [:], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "http://\(kodiIP):\(port)/jsonrpc") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10 // 10 seconds timeout
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": 1
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    NotificationCenter.default.post(name: .sendRequestFailed, object: nil, userInfo: ["error": error.localizedDescription])
                }
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(.success(data))
                NotificationCenter.default.post(name: .sendRequestCompleted, object: nil)
            }
        }
        task.resume()
    }
    
    func fetchMediaInfo() {
        sendRequest(method: "Player.GetProperties", params: ["playerid": playerID, "properties": ["time", "totaltime"]]) { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let time = result["time"] as? [String: Int],
                   let totaltime = result["totaltime"] as? [String: Int] {
                    let currentSeconds = (time["hours"] ?? 0) * 3600 + (time["minutes"] ?? 0) * 60 + (time["seconds"] ?? 0)
                    let totalSeconds = (totaltime["hours"] ?? 0) * 3600 + (totaltime["minutes"] ?? 0) * 60 + (totaltime["seconds"] ?? 0)
                    self.currentPosition = currentSeconds
                    self.totalDuration = totalSeconds
                }
            case .failure(let error):
                print("Failed to fetch media info: \(error.localizedDescription)")
            }
        }
    }
    
    func seek(to position: Int) {
        sendRequest(method: "Player.Seek", params: ["playerid": playerID, "value": position]) { result in
            switch result {
            case .success:
                print("Seeked to \(position) seconds")
            case .failure(let error):
                print("Failed to seek: \(error.localizedDescription)")
            }
        }
    }

    func playPause() {
        sendRequest(method: "Player.PlayPause", params: ["playerid": playerID]) { result in
            switch result {
            case .success:
                print("Play/Pause success")
            case .failure(let error):
                print("Play/Pause failed: \(error.localizedDescription)")
            }
        }
    }

    func stop() {
        sendRequest(method: "Player.Stop", params: ["playerid": 1]) { result in
            self.printResult(result, action: "Stop")
        }
    }

    func fastForward() {
        // Seek forward by 30 seconds
        sendRequest(method: "Player.Seek", params: ["playerid": 1, "value": ["seconds": 30]]) { result in
            self.printResult(result, action: "Fast Forward")
        }
    }

    func rewind() {
        // Seek backward by 30 seconds
        sendRequest(method: "Player.Seek", params: ["playerid": 1, "value": ["seconds": -30]]) { result in
            self.printResult(result, action: "Rewind")
        }
    }

    // Navigation Controls
    func navigate(direction: Direction) {
        sendRequest(method: "Input." + direction.rawValue) { result in
            self.printResult(result, action: direction.rawValue)
        }
    }

    func showInfo() {
        sendRequest(method: "Input.Info") { result in
            self.printResult(result, action: "Info")
        }
    }

    func back() {
        sendRequest(method: "Input.Back") { result in
            self.printResult(result, action: "Back")
        }
    }

    private func printResult(_ result: Result<Data, Error>, action: String) {
        switch result {
        case .success(let data):
            print("\(action) Success: \(data)")
        case .failure(let error):
            print("\(action) Error: \(error)")
            NotificationCenter.default.post(name: .sendRequestFailed, object: nil, userInfo: ["error": error.localizedDescription])
        }
    }
}
