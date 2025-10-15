# Kodi Remote V2 - User Guide

## 🚀 Getting Started

### First Time Setup

1. **Launch the app**
   - On first launch, you'll see "No server configured"
   - Tap the "Configure Server" button or the settings gear icon

2. **Configure Your Kodi Server**
   - Enter your Kodi server's IP address (e.g., 192.168.1.100)
   - Enter the port (default is 8080)
   - Tap "Test Connection" to verify settings
   - If successful, tap "Save"

3. **Start Using**
   - Return to main screen
   - Connection status will show green dot if connected
   - Start playing media on Kodi to see controls activate

---

## 🎮 Controls Overview

### Header Section
- **Title Display**: Shows currently playing media title
- **Connection Status**: 
  - 🟢 Green dot = Connected
  - 🔴 Red dot = Disconnected
- **Settings Button** (gear icon): Configure server settings
- **Volume Button** (speaker icon): Toggle volume controls panel

### Navigation Pad
- **Arrow Buttons**: Navigate Kodi interface
  - Up, Down, Left, Right
- **OK Button** (center): Select/Enter
- **Bottom Row**:
  - ⬅️ Back: Go back in menu
  - 🏠 Home: Return to Kodi home screen
  - ☰ Menu: Open context menu

### Volume Controls (Toggle On/Off)
- **🔇 Mute**: Toggle mute on/off
- **−** : Decrease volume
- **+** : Increase volume

### Playback Controls
- **⏮ Rewind**: Skip back 30 seconds
- **⏯ Play/Pause**: Toggle playback
- **⏹ Stop**: Stop playback completely
- **⏭ Forward**: Skip forward 30 seconds

### Playback Progress
- **Time Display**: Current position / Total duration
- **Slider**: Drag to seek to any position
  - Shows live updates every second
  - Drag to jump to specific time

---

## ✨ New Features

### Haptic Feedback
Every button press now provides tactile feedback:
- Light vibration for navigation
- Medium vibration for playback controls
- Strong vibration for stop button

### Connection Testing
Before saving settings:
1. Enter IP and port
2. Tap "Test Connection"
3. Wait for verification
4. Get instant feedback (success or error)

### Smart Empty States
The app intelligently shows:
- **No Server Configured**: Quick setup button
- **No Active Playback**: Clear message when nothing is playing
- **Loading**: Spinner while fetching data
- **Disconnected**: Red indicator when server unreachable

### Improved Error Handling
When connection fails:
- Clear error message shown
- Option to go directly to Settings
- Suggestions for fixing the issue

---

## 💡 Tips & Tricks

### Volume Control Panel
- Tap the speaker icon in the top-right to show/hide volume controls
- Saves screen space when not needed
- Smooth animation when toggling

### Connection Status
- Always visible under the title
- Automatically updates
- Green = Ready to use
- Red = Check settings or network

### Seeking During Playback
- While dragging the slider, updates pause
- Release to jump to new position
- Haptic feedback confirms seek

### Settings Validation
- Invalid IP addresses are caught immediately
- Port must be between 1-65535
- Can't save invalid settings
- Test before saving to ensure it works

---

## 🔧 Troubleshooting

### "Disconnected" Status
**Possible causes:**
- Kodi server is not running
- Wrong IP address or port
- Network connectivity issue
- Firewall blocking connection

**Solutions:**
1. Check Kodi is running on your device
2. Verify IP address in Settings (gear icon)
3. Test connection from Settings
4. Ensure both devices are on same network
5. Check Kodi's web server is enabled:
   - Settings → Services → Control
   - Enable "Allow remote control via HTTP"

### No Playback Information
**Causes:**
- No media currently playing on Kodi
- Player hasn't started yet

**Solutions:**
- Start playing something on Kodi
- Wait a few seconds for app to update
- App will show "No active playback" message

### Settings Not Saving
**Check:**
- IP address is valid format (e.g., 192.168.1.100)
- Port is a number between 1-65535
- Both fields are filled in
- Test Connection succeeds before saving

### Buttons Not Working
**Solutions:**
1. Check connection status indicator (should be green)
2. Verify Kodi is responding to other remotes
3. Try reconnecting (stop/start app)
4. Test connection in Settings

---

## 📱 Interface Guide

### Main Screen Layout (Top to Bottom)

```
┌─────────────────────────────────────────┐
│  Movie Title               [⚙️] [🔊]    │ ← Header
│  🟢 Connected                           │
├─────────────────────────────────────────┤
│                                         │
│  [🔇] [−] [+]  ← Volume (toggle)       │
│                                         │
│         ⬆️                              │
│      ⬅️ [OK] ➡️   ← Navigation Pad      │
│         ⬇️                              │
│                                         │
│    [⬅️] [🏠] [☰]  ← Navigation Buttons  │
│                                         │
│  00:15:30 ━━━●━━━ 01:45:00  ← Progress │
│                                         │
│  [⏮] [⏯] [⏹] [⏭]  ← Playback Controls │
└─────────────────────────────────────────┘
```

### Settings Screen

```
┌─────────────────────────────────────────┐
│ ← Cancel        Settings                │
├─────────────────────────────────────────┤
│  Kodi Server Settings                   │
│  ┌─────────────────────────────────┐   │
│  │ 192.168.1.100                   │   │ ← IP Address
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │ 8080                            │   │ ← Port
│  └─────────────────────────────────┘   │
│                                         │
│  [    Test Connection    ]              │ ← Test Button
│                                         │
│  [        Save          ]               │ ← Save Button
└─────────────────────────────────────────┘
```

---

## ⚙️ Advanced Settings

### Finding Your Kodi IP Address

**On Kodi:**
1. Go to System → System Info
2. Look for "IP address"
3. Use this IP in the app

**On macOS/Linux:**
- Open Terminal on Kodi device
- Type: `ifconfig` or `ip addr`

**On Windows:**
- Open Command Prompt
- Type: `ipconfig`

### Default Port
- Standard Kodi web port: **8080**
- Check Kodi settings if different:
  - Settings → Services → Control
  - "Port" setting

### Network Requirements
- Both devices must be on same network
- Kodi web server must be enabled
- No firewall blocking port 8080

---

## 🎯 Best Practices

### Connection Management
- Test connection before saving settings
- Keep app updated when network changes
- Note your IP address (it may change)

### Battery Optimization
- App polls every second during playback
- Close app when not in use
- Consider using Kodi's web interface for long sessions

### Smooth Experience
- Keep Kodi and app on same network
- Use wired connection for Kodi when possible
- Minimize network traffic during streaming

---

## 📞 Support

### Connection Issues
1. Verify Kodi web server enabled
2. Test connection from Settings
3. Check firewall settings
4. Ensure same network

### Feature Requests
This is an enhanced version with:
- ✅ Volume controls
- ✅ Navigation buttons
- ✅ Haptic feedback
- ✅ Connection testing
- ✅ Input validation
- ✅ Loading states
- ✅ Error handling

---

## 🔄 Updates & Changes

### Version 2.0 Improvements
- Dynamic player detection
- Settings persistence
- Connection status indicator
- Volume control panel
- Back/Home/Menu buttons
- Haptic feedback on all controls
- Connection testing
- Input validation
- Better error messages
- Loading states
- Empty states with helpful actions

---

## 📚 Quick Reference

| Action | Button | Location |
|--------|--------|----------|
| Navigate Kodi | Arrow buttons | Center |
| Select | OK button | Center |
| Go back | ⬅️ | Bottom row |
| Home screen | 🏠 | Bottom row |
| Context menu | ☰ | Bottom row |
| Volume up | + | Volume panel |
| Volume down | − | Volume panel |
| Mute | 🔇 | Volume panel |
| Play/Pause | ⏯ | Bottom controls |
| Stop | ⏹ | Bottom controls |
| Rewind 30s | ⏮ | Bottom controls |
| Forward 30s | ⏭ | Bottom controls |
| Seek | Drag slider | Above controls |
| Settings | ⚙️ | Top right |
| Volume panel | 🔊 | Top right |

---

Enjoy your enhanced Kodi remote experience! 🎉

