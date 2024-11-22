import SwiftUI
import AudioToolbox

class ColorSchemeSettings: ObservableObject {
    @Published var buttonColor: Color
    @Published var buttonShape: String
    @Published var buttonSize: CGFloat
    @Published var buttonEnableSounds: Bool
    @Published var buttonSoundId: SystemSoundID
    
    private static let keys: [String: String] = [
        "buttonColor": "buttonColorKey",
        "buttonShape": "buttonShapeKey",
        "buttonSize": "buttonSizeKey",
        "buttonEnableSounds": "enableSoundsKey",
        "buttonSoundId": "soundIdKey"
    ]
    
    init() {
        self.buttonColor = ColorSchemeSettings.loadProperty(forKey: ColorSchemeSettings.keys["buttonColor"]!, defaultValue: .red)
        self.buttonShape = ColorSchemeSettings.loadProperty(forKey: ColorSchemeSettings.keys["buttonShape"]!, defaultValue: "Circle")
        self.buttonSize = ColorSchemeSettings.loadProperty(forKey: ColorSchemeSettings.keys["buttonSize"]!, defaultValue: 70)
        self.buttonEnableSounds = ColorSchemeSettings.loadProperty(forKey: ColorSchemeSettings.keys["buttonEnableSounds"]!, defaultValue: true)
        self.buttonSoundId = ColorSchemeSettings.loadProperty(forKey: ColorSchemeSettings.keys["buttonSoundId"]!, defaultValue: SystemSoundID(1107))
    }
    
    // MARK: - Load Methods
    
    private static func loadProperty<T>(forKey key: String, defaultValue: T) -> T {
        switch T.self {
        case is Color.Type:
            return loadColor(forKey: key, defaultValue: defaultValue as! Color) as! T
        case is String.Type:
            return (UserDefaults.standard.string(forKey: key) as? T) ?? defaultValue
        case is CGFloat.Type:
            let value = UserDefaults.standard.double(forKey: key)
            return value > 0 ? CGFloat(value) as! T : defaultValue
        case is SystemSoundID.Type:
            let value = UserDefaults.standard.integer(forKey: key)
            return SystemSoundID(value) as! T
        case is Bool.Type:
            return (UserDefaults.standard.bool(forKey: key) as? T) ?? defaultValue
        default:
            return defaultValue
        }
    }
    
    private static func loadColor(forKey key: String, defaultValue: Color) -> Color {
        guard let colorData = UserDefaults.standard.data(forKey: key),
              let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor else {
            return defaultValue
        }
        return Color(uiColor)
    }
    
    // MARK: - Save Methods
    
    private func saveProperty<T>(value: T, forKey key: String) {
        switch T.self {
        case is Color.Type:
            saveColor(value as! Color, forKey: key)
        case is String.Type:
            UserDefaults.standard.set(value as! String, forKey: key)
        case is CGFloat.Type:
            UserDefaults.standard.set(value as! CGFloat, forKey: key)
        case is SystemSoundID.Type:
            UserDefaults.standard.set(Int(value as! SystemSoundID), forKey: key)
        case is Bool.Type:
            UserDefaults.standard.set(value as! Bool, forKey: key)
        default:
            break
        }
    }
    
    private func saveColor(_ color: Color, forKey key: String) {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: key)
        }
    }
    
    // MARK: - Accessors with Save Logic
    
    var color: Color {
        get { buttonColor }
        set {
            buttonColor = newValue
            saveProperty(value: newValue, forKey: ColorSchemeSettings.keys["buttonColor"]!)
        }
    }
    
    var shape: String {
        get { buttonShape }
        set {
            buttonShape = newValue
            saveProperty(value: newValue, forKey: ColorSchemeSettings.keys["buttonShape"]!)
        }
    }
    
    var size: CGFloat {
        get { buttonSize }
        set {
            buttonSize = newValue
            saveProperty(value: newValue, forKey: ColorSchemeSettings.keys["buttonSize"]!)
        }
    }
    
    var soundsEnabled: Bool {
        get { buttonEnableSounds }
        set {
            buttonEnableSounds = newValue
            saveProperty(value: newValue, forKey: ColorSchemeSettings.keys["buttonEnableSounds"]!)
        }
    }
    
    var selectedSound: SystemSoundID {
        get { buttonSoundId }
        set {
            buttonSoundId = newValue
            saveProperty(value: newValue, forKey: ColorSchemeSettings.keys["buttonSoundId"]!)
        }
    }
}
