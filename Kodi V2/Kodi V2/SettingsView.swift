import SwiftUI

struct SettingsView: View {
    @ObservedObject var kodiClient: KodiClient
    @Environment(\.presentationMode) var presentationMode
    @State private var tempKodiAddress: String
    @State private var tempPort: String
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isTesting = false

    // Initialize with current values
    init(kodiClient: KodiClient) {
        self.kodiClient = kodiClient
        _tempKodiAddress = State(initialValue: kodiClient.kodiAddress)
        _tempPort = State(initialValue: String(kodiClient.port))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kodi Server Settings")) {
                    TextField("IP Address (e.g., 192.168.1.100)", text: $tempKodiAddress)
                        .keyboardType(.decimalPad)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("Port (default: 8080)", text: $tempPort)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Button(action: testConnection) {
                        HStack {
                            Spacer()
                            if isTesting {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isTesting ? "Testing..." : "Test Connection")
                            Spacer()
                        }
                    }
                    .disabled(isTesting || tempKodiAddress.isEmpty || tempPort.isEmpty)
                }
                
                Section {
                    Button("Save") {
                        saveSettings()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(tempKodiAddress.isEmpty || tempPort.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func validateInputs() -> (Bool, String) {
        // Validate IP address
        let ipPattern = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        let ipPredicate = NSPredicate(format: "SELF MATCHES %@", ipPattern)
        
        if !ipPredicate.evaluate(with: tempKodiAddress) {
            return (false, "Please enter a valid IP address (e.g., 192.168.1.100)")
        }
        
        // Validate port
        guard let port = Int(tempPort), port >= 1, port <= 65535 else {
            return (false, "Port must be a number between 1 and 65535")
        }
        
        return (true, "")
    }
    
    private func testConnection() {
        let (isValid, errorMessage) = validateInputs()
        guard isValid else {
            alertTitle = "Invalid Input"
            alertMessage = errorMessage
            showAlert = true
            return
        }
        
        isTesting = true
        
        // Temporarily set the values for testing
        let originalAddress = kodiClient.kodiAddress
        let originalPort = kodiClient.port
        
        kodiClient.kodiAddress = tempKodiAddress
        kodiClient.port = Int(tempPort) ?? 8080
        
        kodiClient.testConnection { success, message in
            DispatchQueue.main.async {
                isTesting = false
                alertTitle = success ? "Success" : "Connection Failed"
                alertMessage = message
                showAlert = true
                
                // Restore original values if test failed
                if !success {
                    kodiClient.kodiAddress = originalAddress
                    kodiClient.port = originalPort
                }
            }
        }
    }
    
    private func saveSettings() {
        let (isValid, errorMessage) = validateInputs()
        guard isValid else {
            alertTitle = "Invalid Input"
            alertMessage = errorMessage
            showAlert = true
            return
        }
        
        kodiClient.kodiAddress = tempKodiAddress
        kodiClient.port = Int(tempPort) ?? 8080
        kodiClient.saveSettings()
        kodiClient.fetchActivePlayers() // Refresh connection with new settings
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    // Create a sample KodiClient for the preview
    let previewKodiClient = KodiClient()
    previewKodiClient.kodiAddress = "192.168.1.100"
    previewKodiClient.port = 8080

    return SettingsView(kodiClient: previewKodiClient)
}

