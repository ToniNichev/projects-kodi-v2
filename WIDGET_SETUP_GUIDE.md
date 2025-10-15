# Kodi Widget Setup Guide

**Feature:** Home Screen Widget for Kodi Remote  
**Date:** October 15, 2025  
**Complexity:** Medium (requires Xcode configuration)

---

## 📱 What You'll Get

A beautiful home screen widget showing:
- Currently playing media
- Movie/TV show thumbnail
- Title, year, and genre
- Playback progress bar
- Time remaining

**Widget Sizes:**
- **Small:** Title + progress
- **Medium:** Thumbnail + full info
- **Large:** Large thumbnail + detailed info

---

## 📋 Prerequisites

- Xcode 14.0 or later
- iOS 14.0 or later target
- Apple Developer account (for App Groups)

---

## 🚀 Setup Instructions

### **Step 1: Add Widget Extension**

1. **Open Xcode** with your `Kodi V2.xcodeproj`

2. **Add Widget Extension:**
   - Click **File** → **New** → **Target...**
   - Select **Widget Extension**
   - Click **Next**
   
3. **Configure Widget:**
   - Product Name: `KodiWidget`
   - Team: Your development team
   - Organization Identifier: `com.kodiremote` (or your identifier)
   - Language: Swift
   - **Uncheck** "Include Configuration Intent"
   - Click **Finish**
   
4. **Activate Scheme:**
   - When prompted "Activate 'KodiWidget' scheme?", click **Activate**

---

### **Step 2: Configure App Group**

App Groups allow the main app and widget to share data.

#### **2a. Enable App Groups for Main App:**

1. Select **Kodi V2** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Click **+** to add a new group
6. Enter: `group.com.kodiremote.v2`
7. Check the checkbox to enable it

#### **2b. Enable App Groups for Widget:**

1. Select **KodiWidget** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Use the **same group**: `group.com.kodiremote.v2`
6. Check the checkbox to enable it

> ⚠️ **Important:** Both targets must use the EXACT same App Group identifier!

---

### **Step 3: Replace Widget Code**

1. **Delete** the auto-generated `KodiWidget.swift` in the KodiWidget folder

2. **Copy** the new `KodiWidget.swift` file:
   - From: `KodiWidget/KodiWidget.swift` (created by me)
   - To: KodiWidget target in your project

3. **Add SharedData.swift to Widget:**
   - Select `SharedData.swift` in Xcode
   - In **File Inspector** (right panel)
   - Under **Target Membership**
   - **Check** both `Kodi V2` AND `KodiWidget`

---

### **Step 4: Update Info.plist (Optional)**

Add custom widget descriptions:

1. Select **KodiWidget** target
2. Open `Info.plist`
3. Add custom display name and description

---

### **Step 5: Build and Run**

1. **Select** `Kodi V2` scheme
2. **Build** the project (⌘B)
3. **Run** on device or simulator (⌘R)

If there are no errors, continue to testing!

---

## 🧪 Testing the Widget

### **Add Widget to Home Screen:**

1. **On Device/Simulator:**
   - Long press on home screen
   - Tap **+** in top-left corner
   - Search for "Kodi"
   - Select "Kodi Playback"
   - Choose size (Small/Medium/Large)
   - Tap **Add Widget**
   - Tap **Done**

2. **Test Playback:**
   - Play media on your Kodi server
   - Open Kodi Remote app
   - Let it connect and fetch playback info
   - Return to home screen
   - Widget should show current playback!

---

## 🎨 Widget Layouts

### **Small Widget (2x2)**
```
┌──────────────┐
│ ▶️ Kodi      │
│              │
│ Movie Title  │
│              │
│ ████████░░░  │
│ 1:23:45      │
└──────────────┘
```

### **Medium Widget (4x2)**
```
┌────────────────────────────────┐
│ [Thumbnail]  The Dark Knight    │
│              2008 • Action       │
│                                  │
│              ████████████░░░     │
│              1:23:45   2:32:00   │
└────────────────────────────────┘
```

### **Large Widget (4x4)**
```
┌────────────────────────────────┐
│                                  │
│    [Large Thumbnail]             │
│                                  │
├────────────────────────────────┤
│  The Dark Knight                 │
│  📅 2008  •  🎬 Action, Crime    │
│                                  │
│  ████████████████░░░             │
│  1:23:45    40%    2:32:00       │
└────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### **Widget Shows "No Playback"**

**Causes:**
- No media playing on Kodi
- App hasn't fetched data yet
- App Group not configured correctly

**Solutions:**
1. Open main app and let it connect
2. Verify media is playing on Kodi
3. Check App Group identifier matches in both targets
4. Force-quit and restart the app

---

### **Widget Not Updating**

**Causes:**
- Widget timeline not refreshing
- Shared data not being saved

**Solutions:**
1. Remove and re-add widget
2. Rebuild the project
3. Check console for errors
4. Verify `SharedDataManager` is being called

---

### **Build Errors**

**"Cannot find 'SharedDataManager' in scope"**
- Solution: Add `SharedData.swift` to KodiWidget target

**"Cannot find 'PlaybackData' in scope"**
- Solution: Ensure `SharedData.swift` is in both targets

**"App Group not found"**
- Solution: Enable App Groups in Signing & Capabilities

---

### **Widget Shows Old Data**

**Causes:**
- Timeline update interval too long
- App not in foreground to update

**Solutions:**
1. Widget updates every 30 seconds when app active
2. Open app to refresh immediately
3. iOS limits background updates to save battery

---

## 🎯 How It Works

### **Data Flow:**

```
1. Kodi plays media
   ↓
2. Kodi Remote app fetches playback info
   ↓
3. KodiClient saves to SharedDataManager
   ↓
4. SharedDataManager writes to App Group
   ↓
5. SharedDataManager triggers widget reload
   ↓
6. Widget reads from App Group
   ↓
7. Widget displays current playback
```

### **Update Frequency:**

- **App Active:** Every 2 seconds (via polling)
- **Widget:** Every 30 seconds (when data available)
- **iOS System:** Additional background updates as allowed

---

## 📊 File Structure

```
Kodi V2/
├── Kodi V2/
│   ├── ...existing files...
│   ├── SharedData.swift          ← NEW (shared)
│   └── KodiClient.swift           ← MODIFIED
└── KodiWidget/                    ← NEW
    ├── KodiWidget.swift           ← NEW
    ├── Assets.xcassets/
    └── Info.plist
```

---

## 🔐 Privacy & Permissions

### **App Groups:**
- Required for data sharing
- Only accessible by your apps
- Data stays on device

### **Network:**
- Widget doesn't make network requests
- Only displays data from main app
- No background network activity

---

## ⚙️ Customization

### **Change Update Interval:**

In `KodiWidget.swift`, modify:
```swift
let nextUpdate = Calendar.current.date(
    byAdding: .second,
    value: 30,  // ← Change this (seconds)
    to: currentDate
)!
```

**Recommendations:**
- **Fast:** 15 seconds (more battery usage)
- **Balanced:** 30 seconds (default)
- **Battery Saver:** 60 seconds

---

### **Change App Group:**

If you want a different identifier:

1. **Update in both capabilities:**
   - Main app: Signing & Capabilities → App Groups
   - Widget: Signing & Capabilities → App Groups

2. **Update in `SharedData.swift`:**
   ```swift
   let appGroupIdentifier = "group.YOUR.IDENTIFIER"
   ```

---

## 📈 Performance

### **Battery Impact:**
- **Minimal** - Widget doesn't run constantly
- Updates when app is active
- iOS manages update frequency
- No background network requests

### **Data Usage:**
- **None** - Widget uses cached data
- No network requests from widget
- Only main app uses network

### **Storage:**
- **Tiny** - < 1 KB for shared data
- Stored in App Group container
- Cleaned up automatically

---

## 🎁 Benefits

### **For Users:**
- 📱 **Glanceable** - See playback without opening app
- ⚡ **Fast** - No need to open app
- 🎨 **Beautiful** - Professional widget design
- 📊 **Informative** - Full media details

### **For You:**
- 🚀 **Premium Feature** - Stands out from competitors
- ⭐ **User Delight** - Widget is highly requested
- 💎 **Professional** - Shows attention to detail
- 🏆 **App Store** - Better visibility & ratings

---

## 🆚 Before & After

### **Before (No Widget):**
```
To see playback:
1. Unlock phone
2. Find Kodi app
3. Open app
4. Wait for connection
5. View info
```

### **After (With Widget):**
```
To see playback:
1. Glance at home screen
   ✅ Done!
```

---

## 🔮 Future Enhancements

### **Potential Additions:**

1. **Interactive Buttons:**
   - Play/Pause button
   - Skip forward/back
   - Stop playback
   (Requires iOS 16+ intents)

2. **Lock Screen Widget:**
   - iOS 16+ feature
   - Show playback on lock screen

3. **Live Activities:**
   - iOS 16+ feature
   - Dynamic Island support

4. **Complications:**
   - Apple Watch widget
   - Glance at wrist

---

## ✅ Checklist

Before deployment:

- [ ] App Groups enabled for both targets
- [ ] Same App Group identifier in both
- [ ] SharedData.swift added to both targets
- [ ] Widget builds without errors
- [ ] Widget appears in widget gallery
- [ ] Widget shows placeholder correctly
- [ ] Widget updates with real playback
- [ ] All sizes tested (Small/Medium/Large)
- [ ] No data when no playback
- [ ] Thumbnail loads (if available)
- [ ] Progress bar animates correctly
- [ ] Time displays formatted properly

---

## 📞 Support

### **Common Issues:**

**Problem:** Widget not in gallery
- **Fix:** Clean build folder (Shift+⌘+K) and rebuild

**Problem:** Shared data not working
- **Fix:** Verify App Group identifiers match exactly

**Problem:** Widget shows stale data
- **Fix:** Remove widget, rebuild app, re-add widget

---

## 📊 Success Metrics

After implementing:

### **User Engagement:**
- Faster access to playback info
- Reduced app opens for status checks
- Better user satisfaction

### **App Quality:**
- Professional feature set
- Competitive advantage
- Better App Store presence

---

## 🎓 Learning Resources

- [Apple Widget Documentation](https://developer.apple.com/documentation/widgetkit)
- [WWDC: Widgets Code-Along](https://developer.apple.com/videos/play/wwdc2020/10034/)
- [App Groups Guide](https://developer.apple.com/documentation/xcode/configuring-app-groups)

---

**Your widget is ready to shine on the home screen!** 🎉

