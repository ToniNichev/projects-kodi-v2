import SwiftUI

struct SettingsView: View {
    @ObservedObject var kodiClient: KodiClient
    @Environment(\.presentationMode) var presentationMode
    @State private var tempKodiAddress: String
    @State private var tempPort: Int

    // Initialize with current values
    init(kodiClient: KodiClient) {
        self.kodiClient = kodiClient
        _tempKodiAddress = State(initialValue: kodiClient.kodiAddress)
        _tempPort = State(initialValue: kodiClient.port)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kodi Server Settings")) {
                    TextField("IP Address", text: $tempKodiAddress)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("Port", value: $tempPort, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }

                Button("Save") {
                    kodiClient.kodiAddress = tempKodiAddress
                    kodiClient.port = tempPort
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    // Create a sample KodiClient for the preview
    let previewKodiClient = KodiClient()
    previewKodiClient.kodiAddress = "http://192.168.1.100:8080/jsonrpc"
    previewKodiClient.port = 9090

    return SettingsView(kodiClient: previewKodiClient)
}

