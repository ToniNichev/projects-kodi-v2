import Foundation
import SwiftUI

class KodiClient: ObservableObject {
    @Published var port: Int = 8080
    @Published var kodiAddress: String = "" // IP only
    @Published var activePlayerID: Int? = nil
    @Published var totalDuration: Double = 0.0
    @Published var playbackPosition: Double = 0.0
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    @Published var isLoading = false
    @Published var isConnected = false

    @Published var currentYear: Int? = nil
    @Published var currentGenre: String = ""
    @Published var currentThumbnail: String? = nil
    @Published var currentMovieTitle: String = "Kodi Remote"
    
    private let kodiAddressKey = "kodiAddressKey"
    private let portKey = "portKey"

    private var timer: Timer?
    
    init() {
        loadSettings()
        fetchActivePlayers()
    }

    enum Direction: String {
        case up = "Up"
        case down = "Down"
        case left = "Left"
        case right = "Right"
    }
    
    enum InputAction: String {
        case back = "Back"
        case home = "Home"
        case contextMenu = "ContextMenu"
        case info = "Info"
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
        guard let playerID = activePlayerID else {
            // No active player, try to fetch active players
            fetchActivePlayers()
            return
        }
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.GetProperties",
            "params": ["playerid": playerID, "properties": ["time", "totaltime"]],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            guard let result = data["result"] as? [String: Any],
                  let time = result["time"] as? [String: Int],
                  let totaltime = result["totaltime"] as? [String: Int],
                  let hours = time["hours"],
                  let minutes = time["minutes"],
                  let seconds = time["seconds"],
                  let totalHours = totaltime["hours"],
                  let totalMinutes = totaltime["minutes"],
                  let totalSeconds = totaltime["seconds"] else {
                return
            }
            
            let currentSeconds = Double(hours * 3600 + minutes * 60 + seconds)
            let totalDurationSeconds = Double(totalHours * 3600 + totalMinutes * 60 + totalSeconds)
            
            DispatchQueue.main.async {
                self.playbackPosition = currentSeconds
                self.totalDuration = totalDurationSeconds
                self.isConnected = true
                
                // Fetch the current item's details if playback is active
                if totalDurationSeconds > 0 {
                    self.fetchCurrentItemDetails()
                }
                
                // Share data with widget
                self.updateSharedPlaybackData()
            }
        }
    }

    func setKodiPlaybackPosition(_ position: Double) {
        guard let playerID = activePlayerID, totalDuration > 0 else { return }
        
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
        guard let playerID = activePlayerID else { return }
        
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
        guard let playerID = activePlayerID else { return }
        
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
        guard let playerID = activePlayerID else { return }
        
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
        guard let playerID = activePlayerID else { return }
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.Stop",
            "params": ["playerid": playerID],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Playback stopped:", data)
            DispatchQueue.main.async {
                self.activePlayerID = nil
                self.totalDuration = 0.0
                self.playbackPosition = 0.0
                self.currentMovieTitle = "Kodi Remote"
                self.currentThumbnail = nil
            }
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
        guard let playerID = activePlayerID else { return }
        
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
    
    // MARK: - Active Player Detection
    
    func fetchActivePlayers() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Player.GetActivePlayers",
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            if let result = data["result"] as? [[String: Any]],
               let firstPlayer = result.first,
               let playerID = firstPlayer["playerid"] as? Int {
                DispatchQueue.main.async {
                    self.activePlayerID = playerID
                    self.isConnected = true
                    // Once we have an active player, fetch playback info
                    self.fetchPlaybackInfo()
                }
            } else {
                DispatchQueue.main.async {
                    self.activePlayerID = nil
                    self.totalDuration = 0.0
                    self.playbackPosition = 0.0
                    self.currentMovieTitle = "Kodi Remote"
                    self.currentThumbnail = nil
                }
            }
        }
    }
    
    // MARK: - Volume Controls
    
    func setVolume(_ volume: Int) {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Application.SetVolume",
            "params": ["volume": volume],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Volume set to \(volume):", data)
        }
    }
    
    func volumeUp() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Application.SetVolume",
            "params": ["volume": "increment"],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Volume increased:", data)
        }
    }
    
    func volumeDown() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Application.SetVolume",
            "params": ["volume": "decrement"],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Volume decreased:", data)
        }
    }
    
    func toggleMute() {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Application.SetMute",
            "params": ["mute": "toggle"],
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("Mute toggled:", data)
        }
    }
    
    // MARK: - Navigation Actions
    
    func sendInputAction(_ action: InputAction) {
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "Input." + action.rawValue,
            "id": 1
        ]
        
        makeKodiRequest(with: body) { data in
            print("\(action.rawValue) action sent:", data)
        }
    }
    
    // MARK: - Widget Data Sharing
    
    func updateSharedPlaybackData() {
        guard totalDuration > 0 else {
            // No playback, clear widget data
            SharedDataManager.shared.clearPlaybackData()
            return
        }
        
        let thumbnailURL: String?
        if let thumbnail = currentThumbnail, !kodiAddress.isEmpty {
            thumbnailURL = "http://\(kodiAddress):\(port)/image/\(thumbnail.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        } else {
            thumbnailURL = nil
        }
        
        let playbackData = PlaybackData(
            title: currentMovieTitle,
            year: currentYear,
            genre: currentGenre != "Unknown Genre" ? currentGenre : nil,
            currentTime: playbackPosition,
            totalTime: totalDuration,
            isPlaying: true, // We can enhance this later with actual play/pause state
            thumbnailURL: thumbnailURL,
            lastUpdated: Date()
        )
        
        SharedDataManager.shared.savePlaybackData(playbackData)
    }
    
    // MARK: - Connection Testing
    
    func testConnection(completion: @escaping (Bool, String) -> Void) {
        guard !kodiAddress.isEmpty else {
            completion(false, "Please enter a Kodi server address")
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "method": "JSONRPC.Ping",
            "id": 1
        ]
        
        let urlString = "http://\(kodiAddress):\(port)/jsonrpc"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            completion(false, "Invalid server address format")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            completion(false, "Failed to create request")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                completion(false, "Connection failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(false, "No response from server")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? String,
                   result == "pong" {
                    DispatchQueue.main.async {
                        self.isConnected = true
                    }
                    completion(true, "Successfully connected to Kodi!")
                } else {
                    completion(false, "Invalid response from server")
                }
            } catch {
                completion(false, "Failed to parse response")
            }
        }.resume()
    }
}
