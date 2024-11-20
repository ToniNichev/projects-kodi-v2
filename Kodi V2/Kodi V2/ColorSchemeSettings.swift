import SwiftUI

class ColorSchemeSettings: ObservableObject {
    @Published var buttonColor: Color
    
    private let buttonColorKey = "buttonColorKey"
    
    init() {
        self.buttonColor = ColorSchemeSettings.loadButtonColor() // Use static method
    }
    
    private func saveButtonColor() {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(buttonColor), requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: buttonColorKey)
            UserDefaults.standard.synchronize() // Force synchronization
        }
    }
    
    static func loadButtonColor() -> Color {
        guard let colorData = UserDefaults.standard.data(forKey: "buttonColorKey"),
              let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor else {
            return .red // Default to red if no color is saved
        }
        return Color(uiColor)
    }
    
    var color: Color {
        get { buttonColor }
        set {
            buttonColor = newValue
            saveButtonColor()
        }
    }
}
