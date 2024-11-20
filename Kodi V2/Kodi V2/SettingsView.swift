import SwiftUI

struct SettingsView: View {
    @ObservedObject var kodiClient: KodiClient
    @ObservedObject var colorSchemeSettings: ColorSchemeSettings // Passed from ContentView
    @Environment(\.presentationMode) var presentationMode
    @State private var tempKodiAddress: String
    @State private var tempPort: Int

    init(kodiClient: KodiClient, colorSchemeSettings: ColorSchemeSettings) {
        self.kodiClient = kodiClient
        self.colorSchemeSettings = colorSchemeSettings
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
                    kodiClient.saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Section(header: Text("Button Color Settings")) {
                    ColorPicker("Select Button Color", selection: $colorSchemeSettings.buttonColor)
                        .padding()
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
        }
    }
}

#Preview {
    let previewKodiClient = KodiClient()
    let previewColorSchemeSettings = ColorSchemeSettings()

    return SettingsView(kodiClient: previewKodiClient, colorSchemeSettings: previewColorSchemeSettings)
}
