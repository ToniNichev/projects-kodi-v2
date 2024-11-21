import Foundation
import SwiftUI

class KodiClient: ObservableObject {
    @Published var port: Int = 8080
    @Published var kodiAddress: String = "10.0.1.119" // IP only
    private let playerID = 1
    @Published var totalDuration: Double = 100.0
    @Published var playbackPosition: Double = 0.0
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    @State var isSeeking: Bool = false

    @Published var currentYear: Int? = nil
    @Published var currentGenre: String = ""
    @Published var currentThumbnail: String? = nil
    @Published var currentMovieTitle: String = "Kodi Remote"
    
    private let kodiAddressKey = "kodiAddressKey"
    private let portKey = "portKey"

    private var timer: Timer?

    enum Direction: String {
        case up = "Up"
        case down = "Down"
        case left = "Left"
        case right = "Right"
    }
    
    init() {
        loadSettings()
    }
    
    func saveSettings() {
        UserDefaults.standard.set(kodiAddress, forKey: kodiAddressKey)
        UserDefaults.standard.set(port, forKey: portKey)
    }

    func loadSettings() {
        if let savedAddress = UserDefaults.standard.string(forKey: kodiAddressKey) {
            kodiAddress = savedAddress
        }
        if let savedPort = UserDefaults.standard.value(forKey: portKey) as? Int {
            port = savedPort
        }
    }
    

    // MARK: - Common Request and Result Handling

    func makeKodiRequest(with body: [String: Any], completion: (([String: Any]) -> Void)? = nil) {
        let urlString = "http://\(kodiAddress):\(port)/jsonrpc"
        guard let url = URL(string: urlString) else {
            handleRequestError(NSError(domain: "Invalid URL", code: -1), message: "Failed to create URL.")
            return
        }
        
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
                    
                    // Fetch the current item's details if playback is active
                    if totalSeconds > 0 {
                        self.fetchCurrentItemDetails()
                    }
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
    
    func fetchCurrentItemDetails() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.GetItem",
            "params": [
                "playerid": playerID,
                "properties": ["title", "artist", "album", "genre", "thumbnail", "fanart", "year", "rating"]
            ],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            if let result = data["result"] as? [String: Any],
               let item = result["item"] as? [String: Any] {
                
                // Parse metadata
                let title = item["title"] as? String ?? item["label"] as? String ?? "Unknown Title"
                let thumbnail = item["thumbnail"] as? String
                let year = item["year"] as? Int
                let genre = item["genre"] as? [String]
                
                DispatchQueue.main.async {
                    // Update published properties for UI binding
                    self.currentMovieTitle = title
                    self.currentYear = year
                    self.currentGenre = genre?.joined(separator: ", ") ?? "Unknown Genre"
                    self.currentThumbnail = thumbnail
                }
            }
        }
    }
}
