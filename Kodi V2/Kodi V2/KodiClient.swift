import Foundation
import SwiftUI

class KodiClient: ObservableObject {
    @Published var port: Int = 8080
    private let playerID = 1
    @Published var totalDuration: Double = 100.0
    @Published var playbackPosition: Double = 0.0
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""

    // let kodiAddress = "http://10.0.1.119:8080/jsonrpc"
    let kodiAddress = "http://192.168.1.200:8080/jsonrpc"
    private var timer: Timer?

    enum Direction: String {
        case up = "Up"
        case down = "Down"
        case left = "Left"
        case right = "Right"
    }

    // MARK: - Common Request and Result Handling

    func makeKodiRequest(with body: [String: Any], completion: (([String: Any]) -> Void)? = nil) {
        guard let url = URL(string: kodiAddress) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            handleRequestError(error, message: "Failed to create JSON data.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.handleRequestError(error, message: "Connection error.")
                return
            }
            
            guard let data = data else {
                self.handleRequestError(NSError(domain: "No data", code: -1), message: "No data received.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion?(json)
                } else {
                    self.handleRequestError(NSError(domain: "Invalid JSON", code: -1), message: "Failed to parse JSON.")
                }
            } catch {
                self.handleRequestError(error, message: "Parsing error.")
            }
        }.resume()
    }

    private func handleRequestError(_ error: Error, message: String) {
        DispatchQueue.main.async {
            self.errorMessage = "\(message): \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }

    private func handleResult(_ result: Result<[String: Any], Error>, completion: (([String: Any]) -> Void)? = nil) {
        switch result {
        case .success(let data):
            completion?(data)
        case .failure(let error):
            handleRequestError(error, message: "Operation failed")
        }
    }

    // MARK: - Public API Methods
    
    func sendSelectAction() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Input.Select",
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Select action sent:", data)
        }
    }

    func fetchPlaybackInfo() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.GetProperties",
            "params": ["playerid": playerID, "properties": ["time", "totaltime"]],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            if let result = data["result"] as? [String: Any],
               let time = result["time"] as? [String: Int],
               let totaltime = result["totaltime"] as? [String: Int] {
                
                let currentSeconds = Double(time["hours"]! * 3600 + time["minutes"]! * 60 + time["seconds"]!)
                let totalSeconds = Double(totaltime["hours"]! * 3600 + totaltime["minutes"]! * 60 + totaltime["seconds"]!)
                
                DispatchQueue.main.async {
                    self.playbackPosition = currentSeconds
                    self.totalDuration = totalSeconds
                }
            }
        }
    }

    func setKodiPlaybackPosition(_ position: Double) {
        let percentage = (position / totalDuration) * 100
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.Seek",
            "params": [
                "playerid": playerID,
                "value": ["percentage": Int(percentage)]
            ],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            // print("Playback position updated:", data)
        }
    }

    func togglePlayPause() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.PlayPause",
            "params": ["playerid": playerID],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Play/Pause toggled:", data)
        }
    }

    func rewind() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.Seek",
            "params": ["playerid": playerID, "value": ["seconds": -30]],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Rewind triggered:", data)
        }
    }

    func fastForward() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.Seek",
            "params": ["playerid": playerID, "value": ["seconds": 30]],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Fast forward triggered:", data)
        }
    }

    func stopPlayback() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.Stop",
            "params": ["playerid": playerID],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Playback stopped:", data)
        }
    }

    func sendDirection(_ direction: Direction) {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Input." + direction.rawValue,
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Direction \(direction.rawValue) sent:", data)
        }
    }
}
