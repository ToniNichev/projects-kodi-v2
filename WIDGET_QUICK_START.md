# Widget Quick Start

## 🚀 5-Minute Setup

### **What's Ready:**
✅ All widget code created  
✅ Shared data infrastructure  
✅ Three widget sizes (Small/Medium/Large)  
✅ Auto-updating timeline  
✅ Professional UI design  

---

## 📝 Quick Setup (Xcode Required)

### **Step 1: Add Widget Extension** (2 minutes)
```
File → New → Target → Widget Extension
Name: "KodiWidget"
Uncheck "Include Configuration Intent"
```

### **Step 2: Enable App Groups** (2 minutes)
```
Main App Target:
  Signing & Capabilities → + Capability → App Groups
  Add: group.com.kodiremote.v2
  
Widget Target:
  Signing & Capabilities → + Capability → App Groups
  Add: group.com.kodiremote.v2  (same!)
```

### **Step 3: Add Files** (1 minute)
```
1. Replace auto-generated KodiWidget.swift with:
   KodiWidget/KodiWidget.swift (I created this)
   
2. Add SharedData.swift to BOTH targets:
   - Check "Kodi V2" target
   - Check "KodiWidget" target
```

### **Step 4: Build & Run**
```
⌘B to build
⌘R to run
```

---

## 🎯 Add Widget to Home Screen

1. Long press home screen
2. Tap **+** (top-left)
3. Search "Kodi"
4. Choose size
5. Done!

---

## 📊 Widget Sizes

**Small (2x2):**
- Title
- Progress bar
- Time

**Medium (4x2):**
- Thumbnail
- Title + Metadata
- Progress + Times

**Large (4x4):**
- Large thumbnail
- Full metadata
- Detailed progress

---

## ⚠️ Important

**Must use EXACT same App Group ID in both targets:**
```
group.com.kodiremote.v2
```

---

## 🆘 Troubleshooting

**Widget not showing:**
→ Rebuild project (Shift+⌘+K, then ⌘B)

**"Cannot find SharedDataManager":**
→ Add SharedData.swift to KodiWidget target

**Widget shows "No Playback":**
→ Open app, let it connect to Kodi

---

## 📖 Full Documentation

See **WIDGET_SETUP_GUIDE.md** for:
- Detailed instructions
- Troubleshooting guide
- Customization options
- Screenshots & examples

---

## ✅ Files Created

```
Kodi V2/Kodi V2/
  SharedData.swift          ← Data sharing infrastructure
  
KodiWidget/
  KodiWidget.swift          ← Widget UI & logic
  
Documentation/
  WIDGET_SETUP_GUIDE.md     ← Full guide
  WIDGET_QUICK_START.md     ← This file
```

---

## 🎉 That's It!

Your widget is ready! Just follow the 4 steps above and you'll have a beautiful home screen widget in 5 minutes.

**See WIDGET_SETUP_GUIDE.md for details!**

