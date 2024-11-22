import SwiftUI
import AudioToolbox

struct ControlButton: View {
    let imageName: String
    let action: () -> Void
    let buttonColor: Color
    let buttonShape: String
    let buttonSize: CGFloat
    let enableSounds: Bool
    let soundID: SystemSoundID
    // private let soundPlayer = SoundPlayer() // Create an instance of SoundPlayer
    
    var body: some View {
        Button(action: {
            if enableSounds {
                // soundPlayer.playSound(named: soundName)
                AudioServicesPlaySystemSound(soundID) // Play system sound
            }
            action()
        }) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)
                .background(buttonColor)
                .clipShape(getShape())
                .shadow(radius: 5)
        }
    }
    
    private func getShape() -> AnyShape {
        switch buttonShape {
        case "Circle":
            return AnyShape(Circle())
        case "Rectangle":
            return AnyShape(RoundedRectangle(cornerRadius: 10))
        case "Capsule":
            return AnyShape(Capsule())
        default:
            return AnyShape(Circle())
        }
    }
}

#Preview {
    ControlButton(imageName: "plus",
                  action: {},
                  buttonColor: .red,
                  buttonShape: "Circle",
                  buttonSize: 50,
                  enableSounds: true,
                  soundID: 1104)
}
