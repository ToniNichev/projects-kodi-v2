import SwiftUI
import AudioToolbox

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
                
                Section(header: Text("Button Appearance")) {
                    ColorPicker("Select Button Color", selection: $colorSchemeSettings.buttonColor)
                        .padding()

                    Picker("Button Shape", selection: $colorSchemeSettings.buttonShape) {
                        Text("Circle").tag("Circle")
                        Text("Rectangle").tag("Rectangle")
                        Text("Capsule").tag("Capsule")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Slider(value: $colorSchemeSettings.buttonSize, in: 50...85, step: 1) {
                        Text("Button Size")
                    }
                    .padding()
                    .accentColor(colorSchemeSettings.buttonColor)
                    
                    Text("Size: \(Int(colorSchemeSettings.buttonSize)) px")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Sound Settings")) {
                    Toggle("Enable Sounds", isOn: $colorSchemeSettings.buttonEnableSounds)

                    // Use Int binding for the Picker
                    Picker("Sound Effect", selection: Binding(
                        get: { Int(colorSchemeSettings.buttonSoundId) }, // Convert SystemSoundID to Int
                        set: { colorSchemeSettings.buttonSoundId = SystemSoundID($0) } // Convert Int to SystemSoundID
                    )) {
                        Text("Tink").tag(1104)
                        Text("Chord").tag(1105)
                        Text("Bloom").tag(1107)
                        Text("Fanfare").tag(1110)
                        Text("Tweet").tag(1151)
                    }
                    
                    Toggle("Enable Vibration", isOn: $colorSchemeSettings.enableVibration)
                }
                
                Button("Save") {
                    // Save the Kodi server settings
                    kodiClient.kodiAddress = tempKodiAddress
                    kodiClient.port = tempPort
                    kodiClient.saveSettings()

                    // Save the color scheme settings
                    colorSchemeSettings.color = colorSchemeSettings.buttonColor
                    colorSchemeSettings.shape = colorSchemeSettings.buttonShape
                    colorSchemeSettings.size = colorSchemeSettings.buttonSize
                    colorSchemeSettings.soundsEnabled = colorSchemeSettings.buttonEnableSounds
                    colorSchemeSettings.selectedSound = colorSchemeSettings.buttonSoundId
                    
                    // Dismiss the view
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
    let previewKodiClient = KodiClient()
    let previewColorSchemeSettings = ColorSchemeSettings()

    return SettingsView(kodiClient: previewKodiClient, colorSchemeSettings: previewColorSchemeSettings)
}
