# Quick Start Guide

## Testing the POC on Your E-ink Tablet

### Prerequisites

1. **Android tablet** with e-ink display (your Allwinner PB1041)
2. **USB cable** for ADB connection
3. **Computer** with:
   - Android Studio Hedgehog or later
   - Android SDK Platform 34
   - Android NDK 25.x+
   - Git

### Step 1: Enable Developer Options

On your tablet:
1. Go to **Settings > About tablet**
2. Tap **Build number** 7 times
3. Go back to **Settings > Developer options**
4. Enable **USB debugging**
5. Enable **Stay awake** (optional, helpful for testing)

### Step 2: Connect Tablet

```bash
# Connect tablet via USB
# Accept USB debugging prompt on tablet

# Verify connection
adb devices

# You should see:
# List of devices attached
# XXXXXXXX    device
```

### Step 3: Clone and Build

```bash
# Clone repository
git clone https://github.com/NUbem000/AndroidXiboclienteink.git
cd AndroidXiboclienteink

# Open in Android Studio
# File > Open > Select AndroidXiboclienteink folder

# Wait for Gradle sync to complete

# Build project
./gradlew assembleDebug

# Or click "Run" button in Android Studio
```

### Step 4: Install APK

Option A - Android Studio:
1. Click **Run** (Shift + F10)
2. Select your device from list
3. App will install and launch

Option B - Command line:
```bash
# Install debug APK
./gradlew installDebug

# Or manually
adb install app/build/outputs/apk/debug/app-debug.apk

# Launch app
adb shell am start -n com.xibo.eink/.ui.activities.MainActivity
```

### Step 5: Test E-ink Controller

The POC app provides 4 test buttons:

1. **Full Refresh**
   - Triggers complete screen redraw
   - Clears any ghosting
   - Should take ~800ms

2. **Partial Refresh**
   - Fast screen update
   - May show ghosting after multiple uses
   - Should take ~200ms

3. **Clear Screen**
   - Resets display
   - Equivalent to full refresh

4. **Test Pattern**
   - Alternates between black and white screen
   - Good for testing refresh quality

### Expected Behavior

#### If E-ink Device Available:
- Status shows: "✓ E-ink display initialized"
- Device info displays tablet specs
- Buttons trigger visible screen refreshes
- Refresh count increments

#### If E-ink Device NOT Available:
- Status shows: "✗ E-ink device not available"
- App runs in standard mode
- Buttons still work (using standard Android rendering)
- Good for testing UI without e-ink hardware

### Troubleshooting

#### App crashes on launch
```bash
# Check logs
adb logcat | grep XiboEink

# Look for errors in native library loading
adb logcat | grep eink_controller
```

**Common issues:**
- Native library not found → Check NDK configuration
- Permission denied → Check device permissions

#### E-ink device not detected
```bash
# Check if device node exists
adb shell ls -l /dev/eink*
adb shell ls -l /dev/epd*

# Check permissions
adb shell "su -c chmod 666 /dev/eink-panel"  # If rooted
```

Possible device paths:
- `/dev/eink-panel`
- `/dev/epd`
- `/dev/epd0`
- Device-specific path

#### No visible refresh
- E-ink driver may not be accessible
- May need root permissions
- Driver interface may differ from expected
- Check device-specific documentation

### Next Steps

Once POC is working:

1. **Verify Refresh Modes**
   - Test different refresh speeds
   - Observe ghosting behavior
   - Count refresh operations

2. **Test with Content**
   - Display images
   - Render text
   - Try different layouts

3. **Measure Performance**
   - Time refresh operations
   - Monitor battery usage
   - Check memory consumption

4. **Document Results**
   - Share device info
   - Report issues on GitHub
   - Contribute improvements

### Getting Help

- **GitHub Issues**: Report bugs
- **Discussions**: Ask questions
- **Pull Requests**: Contribute fixes

### Developer Mode

To enable verbose logging:

```bash
# Enable debug logs
adb shell setprop log.tag.EinkController VERBOSE
adb shell setprop log.tag.XiboEink DEBUG

# View logs
adb logcat -s EinkController:V XiboEink:D
```

### Building Release APK

```bash
# Build release (unsigned)
./gradlew assembleRelease

# APK location:
# app/build/outputs/apk/release/app-release-unsigned.apk

# For production, configure signing in build.gradle.kts
```

---

**Ready to test?** Connect your tablet and run the app! 🚀
