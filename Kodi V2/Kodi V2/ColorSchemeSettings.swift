import SwiftUI

class ColorSchemeSettings: ObservableObject {
    @Published var buttonColor: Color
    @Published var buttonShape: String
    @Published var buttonSize: CGFloat = 70 // Default size
    
    private let buttonColorKey = "buttonColorKey"
    private let buttonShapeKey = "buttonShapeKey"
    private let buttonSizeKey = "buttonSizeKey"
    
    init() {
        self.buttonColor = ColorSchemeSettings.loadButtonColor()
        self.buttonShape = ColorSchemeSettings.loadButtonShape()
        self.buttonSize = loadButtonSize()
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
    
    private func saveButtonShape() {
        UserDefaults.standard.set(buttonShape, forKey: buttonShapeKey)
        UserDefaults.standard.synchronize() // Force synchronization
    }
    
    static func loadButtonShape() -> String {
        return UserDefaults.standard.string(forKey: "buttonShapeKey") ?? "Circle" // Default to Circle
    }
    
    private func saveButtonSize() {
        UserDefaults.standard.set(buttonSize, forKey: buttonSizeKey)
    }

    private func loadButtonSize() -> CGFloat {
        return CGFloat(UserDefaults.standard.double(forKey: buttonSizeKey)) > 0 ?
            CGFloat(UserDefaults.standard.double(forKey: buttonSizeKey)) :
            70 // Default size
    }
    
    
    var color: Color {
        get { buttonColor }
        set {
            buttonColor = newValue
            saveButtonColor()
        }
    }
    
    var shape: String {
        get { buttonShape }
        set {
            buttonShape = newValue
            saveButtonShape()
        }
    }
    
    var size: CGFloat {
        get { buttonSize }
        set {
            buttonSize = newValue
            saveButtonSize()
        }
    }
}
