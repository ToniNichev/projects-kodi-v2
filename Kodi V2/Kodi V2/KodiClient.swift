import Foundation

class KodiClient: ObservableObject {
    @Published var kodiIP: String = "10.0.1.119" // replace with Kodi IP
    private let port = 8080
    
    func sendRequest(method: String, params: [String: Any] = [:], completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "http://\(kodiIP):\(port)/jsonrpc") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
    
    func playPause() {
        sendRequest(method: "Player.PlayPause", params: ["playerid": 1]) { result in
            switch result {
            case .success(let data):
                print("Play/Pause Success: \(data)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func stop() {
        sendRequest(method: "Player.Stop", params: ["playerid": 1]) { result in
            switch result {
            case .success(let data):
                print("Stop Success: \(data)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    // Navigation Controls
    func navigate(direction: String) {
        sendRequest(method: "Input." + direction) { result in
            self.printResult(result, action: direction.capitalized)
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
        }
    }
}
