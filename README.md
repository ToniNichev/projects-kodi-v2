# Kodi Remote V2 for iOS

<div align="center">

A modern, feature-rich iOS remote control for Kodi media center built with SwiftUI.

**Control your Kodi media center from your iPhone with an intuitive, native iOS interface.**

</div>

---

## ✨ Features

### 🎮 Complete Remote Control
- **Navigation Pad**: Full directional control (Up, Down, Left, Right, OK)
- **Back Button**: Navigate back in menus
- **Home Button**: Return to Kodi home screen
- **Context Menu**: Access Kodi context menus
- **Haptic Feedback**: Tactile response on every button press

### 🎵 Playback Controls
- **Play/Pause**: Toggle playback
- **Stop**: Stop media completely
- **Seek**: Skip forward/backward 30 seconds
- **Progress Slider**: Drag to jump to any position
- **Real-time Updates**: Live playback position tracking

### 🔊 Volume Management
- **Volume Up/Down**: Precise volume control
- **Mute Toggle**: Quick mute/unmute
- **Toggleable Panel**: Show/hide to save screen space
- **Smooth Animations**: Spring-based UI transitions

### 📡 Smart Connection
- **Connection Status**: Live indicator (green = connected, red = disconnected)
- **Auto-detection**: Automatically finds active media players
- **Connection Testing**: Verify settings before saving
- **Persistent Settings**: Server config saved between sessions

### 🎨 Beautiful UI
- **Dynamic Backgrounds**: Current media thumbnail as background
- **Loading States**: Clear feedback when fetching data
- **Empty States**: Helpful messages when nothing is playing
- **Error Handling**: User-friendly error messages with actions

---

## 🚀 Getting Started

### Requirements
- iOS 15.0 or later
- Kodi media center with web server enabled
- Both devices on the same network

### Installation
1. Open the project in Xcode
2. Build and run on your iOS device
3. Configure your Kodi server settings

### First-Time Setup
1. **Enable Kodi Web Server**:
   - On Kodi: Settings → Services → Control
   - Enable "Allow remote control via HTTP"
   - Note the port (default: 8080)

2. **Find Your Kodi IP Address**:
   - On Kodi: System → System Info
   - Look for IP address

3. **Configure the App**:
   - Tap settings gear icon
   - Enter Kodi IP address (e.g., 192.168.1.100)
   - Enter port (default: 8080)
   - Tap "Test Connection"
   - If successful, tap "Save"

---

## 📱 Screenshots

### Main Interface
- Dynamic background from current media
- Connection status indicator
- Volume control panel (toggleable)
- Navigation pad with directional controls
- Playback controls with progress slider

### Settings
- IP address and port configuration
- Connection testing
- Input validation
- User-friendly error messages

---

## 🔧 Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **ObservableObject**: Reactive state management
- **Combine**: Async operations and timers
- **MVVM Pattern**: Clean separation of concerns

### Key Components

#### `KodiClient.swift`
- Network communication via Kodi JSON-RPC API
- State management for playback and connection
- Dynamic player detection
- Settings persistence via UserDefaults

#### `ContentView.swift`
- Main remote control interface
- Haptic feedback integration
- Real-time playback updates
- Responsive UI with loading/empty states

#### `SettingsView.swift`
- Server configuration
- Input validation (IP address, port range)
- Connection testing
- User-friendly error feedback

### API Integration
Uses Kodi's JSON-RPC API:
- `Player.GetActivePlayers` - Detect active media players
- `Player.GetProperties` - Fetch playback info
- `Player.PlayPause` - Control playback
- `Player.Seek` - Skip forward/backward
- `Input.*` - Navigation controls
- `Application.SetVolume` - Volume control
- `JSONRPC.Ping` - Connection testing

---

## 🎯 Recent Improvements

### Version 2.0 Enhancements

#### Critical Fixes ✅
- Fixed hardcoded IP addresses
- Implemented settings persistence
- Replaced force unwrapping with safe optional handling
- Dynamic player ID detection
- Fixed state management issues

#### New Features ✅
- Volume controls with toggleable panel
- Navigation buttons (Back, Home, Menu)
- Haptic feedback on all controls
- Connection testing before saving
- Real-time connection status indicator

#### UX Improvements ✅
- Loading states with progress indicators
- Empty states with helpful actions
- Improved error messages
- Input validation for IP and port
- Better visual feedback

See [IMPROVEMENTS.md](IMPROVEMENTS.md) for detailed changelog.

---

## 📖 Documentation

- **[User Guide](USER_GUIDE.md)**: Complete user manual with tips and troubleshooting
- **[Improvements](IMPROVEMENTS.md)**: Detailed list of all enhancements and fixes

---

## 🛠️ Development

### Project Structure
```
Kodi V2/
├── Kodi V2/
│   ├── Kodi_V2App.swift       # App entry point
│   ├── ContentView.swift      # Main remote interface
│   ├── SettingsView.swift     # Settings configuration
│   ├── KodiClient.swift       # Network & state management
│   ├── Extensions.swift       # Helper extensions
│   └── Assets.xcassets/       # App assets
├── README.md                   # This file
├── USER_GUIDE.md              # User documentation
└── IMPROVEMENTS.md            # Changelog
```

### Building
```bash
# Clone the repository
cd ios/projects-kodi-v2

# Open in Xcode
open "Kodi V2.xcodeproj"

# Build and run (⌘R)
```

### Code Quality
- ✅ Zero linter errors
- ✅ Safe optional handling throughout
- ✅ Proper error handling
- ✅ SwiftUI best practices
- ✅ Reactive state management

---

## 🔐 Privacy & Security

- **No Data Collection**: App doesn't collect or transmit any user data
- **Local Network Only**: Communicates only with your Kodi server
- **Settings Storage**: Server config stored securely in UserDefaults
- **No External Dependencies**: Pure Swift/SwiftUI implementation

---

## 🐛 Troubleshooting

### Connection Issues
- Ensure Kodi web server is enabled
- Verify both devices on same network
- Check firewall settings
- Test connection from Settings

### No Playback Information
- Start playing media on Kodi
- Wait a few seconds for detection
- Check connection status indicator

### Settings Not Saving
- Validate IP address format
- Ensure port is between 1-65535
- Test connection before saving

See [User Guide](USER_GUIDE.md) for more detailed troubleshooting.

---

## 🚧 Known Limitations

- Single server configuration (no profiles)
- Polling-based updates (1-second interval)
- No image caching (may reload thumbnails)
- No subtitle or audio track controls (planned)

---

## 🗺️ Roadmap

### Planned Features
- [ ] Multiple server profiles
- [ ] Image caching for thumbnails
- [ ] Optimized polling interval (battery)
- [ ] Subtitle toggle
- [ ] Audio track selection
- [ ] Playback speed control
- [ ] Widget support
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration
- [ ] iPad-optimized layout
- [ ] Accessibility improvements
- [ ] Localization (i18n)

---

## 📄 License

This project is for personal use. Kodi is a registered trademark of the XBMC Foundation.

---

## 🙏 Acknowledgments

- **Kodi Project**: For the amazing media center software
- **Kodi JSON-RPC API**: For comprehensive remote control capabilities
- **SwiftUI**: For modern iOS development framework

---

## 📞 Support

### Resources
- [Kodi Documentation](https://kodi.wiki/)
- [Kodi JSON-RPC API](https://kodi.wiki/view/JSON-RPC_API)
- [User Guide](USER_GUIDE.md)

### Getting Help
1. Check the [User Guide](USER_GUIDE.md)
2. Review [Troubleshooting](#-troubleshooting) section
3. Verify Kodi web server is enabled
4. Test connection from Settings

---

<div align="center">

**Made with ❤️ for Kodi users**

Control your media center from anywhere in your home!

</div>

