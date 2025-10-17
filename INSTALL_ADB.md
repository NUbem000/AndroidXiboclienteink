# Installing ADB and Running Tests

## Quick Setup for macOS

Since we need ADB tools to test the app, here's how to set it up quickly:

### Option 1: Homebrew (Fastest)

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Android Platform Tools (includes ADB)
brew install --cask android-platform-tools

# Verify installation
adb version
```

### Option 2: Direct Download

```bash
# Download Platform Tools
cd ~/Downloads
curl -O https://dl.google.com/android/repository/platform-tools-latest-darwin.zip

# Extract
unzip platform-tools-latest-darwin.zip

# Move to /usr/local
sudo mv platform-tools /usr/local/

# Add to PATH
echo 'export PATH="/usr/local/platform-tools:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify
adb version
```

---

## Step-by-Step Testing Process

### 1. Prepare Your Tablet

1. **Enable Developer Options:**
   - Go to **Settings** → **About tablet**
   - Find **Build number**
   - Tap it **7 times** rapidly
   - You'll see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to **Settings** → **System** → **Developer options**
   - Enable **USB debugging**
   - Enable **Stay awake** (optional, keeps screen on)

3. **Connect via USB:**
   - Use USB-C cable
   - Connect tablet to computer
   - Tablet will show **"Allow USB debugging?"** prompt
   - Check **"Always allow from this computer"**
   - Tap **OK**

### 2. Verify Connection

```bash
# Check if device is detected
adb devices

# Expected output:
# List of devices attached
# NX3E0800019220W00019    device

# If shows "unauthorized", check tablet screen for prompt
# If shows "offline", try:
adb kill-server
adb start-server
adb devices
```

### 3. Get Device Information

```bash
# Device model
adb shell getprop ro.product.model
# Expected: PB1041

# Manufacturer
adb shell getprop ro.product.manufacturer
# Expected: Allwinner

# Android version
adb shell getprop ro.build.version.release

# Check for e-ink device
adb shell "ls -l /dev/eink* 2>/dev/null || ls -l /dev/epd* 2>/dev/null || echo 'E-ink device not found at standard paths'"
```

### 4. Run Automated Test Script

```bash
cd /Users/david/AndroidXiboclienteink

# Make script executable (if not already)
chmod +x scripts/install_and_test.sh

# Run tests
./scripts/install_and_test.sh
```

The script will:
- ✅ Check ADB connection
- ✅ Build APK
- ✅ Install app
- ✅ Launch app
- ✅ Monitor logs
- ✅ Provide testing instructions

### 5. Manual Testing on Device

Once app is running, perform these tests **on the tablet screen**:

#### Test A: Full Refresh
1. Tap **"Full Refresh"** button
2. **Observe**: Screen flashes and redraws (~800ms)
3. **Check**: Refresh count = 1
4. **Expected**: Clean white screen, no ghosting

#### Test B: Partial Refresh (10x)
1. Tap **"Partial Refresh"** 10 times
2. **Observe**: Fast updates (~200ms each)
3. **Check**: Count increments 1→2→...→10
4. **Expected**: On 10th tap, auto full refresh clears ghosting

#### Test C: Clear Screen
1. Tap **"Clear Screen"**
2. **Observe**: Screen clears
3. **Expected**: Back to clean white

#### Test D: Test Pattern (20x)
1. Tap **"Test Pattern"** 20 times rapidly
2. **Observe**: Alternates white ⬜ and black ⬛
3. **Check**: Pattern visible and clear
4. **Expected**: Auto-refresh every 10 taps prevents ghosting buildup

### 6. Monitor Logs (Another Terminal)

```bash
# Watch app logs in real-time
adb logcat -s EinkController:V XiboEink:D MainActivity:D

# Save logs to file
adb logcat > test_logs.txt

# Check for errors
adb logcat | grep -E "ERROR|FATAL|crash"
```

### 7. Capture Results

```bash
# Take screenshot
adb shell screencap -p /sdcard/xibo_test.png
adb pull /sdcard/xibo_test.png .

# Get memory stats
adb shell dumpsys meminfo com.xibo.eink

# Check if app is running
adb shell "ps | grep xibo"
```

---

## Expected Test Results

### ✅ Success Indicators

1. **App Launches**
   - Fullscreen display
   - No crashes
   - UI is visible

2. **Device Detection**
   - Status shows device info
   - Manufacturer: Allwinner
   - Model: PB1041

3. **E-ink Controller**
   - Either shows "initialized" (device accessible)
   - Or "not available" (device restricted - normal)

4. **Buttons Respond**
   - All 4 buttons tap and respond
   - Toast messages appear
   - Counters update

5. **No Crashes**
   - App stays running
   - No ANR dialogs
   - Logs show no FATAL errors

### ⚠️ Expected Limitations

- **E-ink device may not be accessible** without root
  - This is NORMAL
  - App will run in standard Android display mode
  - UI testing still works
  - Native e-ink features need device access

- **Refresh operations** may not be visible
  - If `/dev/eink-panel` is not accessible
  - JNI calls will log but not execute
  - This validates the code structure
  - Real e-ink control needs root or proper permissions

---

## Troubleshooting

### "adb: command not found"
```bash
# Install via Homebrew
brew install --cask android-platform-tools

# Or add to PATH if already downloaded
export PATH="/path/to/platform-tools:$PATH"
```

### "device unauthorized"
- Check tablet screen for USB debugging prompt
- Tap "Always allow"
- If prompt doesn't appear:
  ```bash
  adb kill-server
  adb start-server
  ```

### "device offline"
```bash
# Restart ADB
adb kill-server
adb start-server

# Reconnect USB cable

# Try different USB port
```

### Build fails
```bash
# Clean build
./gradlew clean
./gradlew assembleDebug

# Check Java version
java -version
# Needs JDK 17+

# Check Gradle
./gradlew --version
```

### App crashes on launch
```bash
# Check logs immediately
adb logcat -d > crash_log.txt

# Look for exception
grep "FATAL" crash_log.txt

# Common issues:
# - Native library architecture mismatch
# - Missing permissions
# - Device incompatibility
```

### E-ink device not found
```bash
# Try different device paths
adb shell "ls -l /dev/ | grep -E 'eink|epd|fb'"

# Check if rooted
adb shell "su -c 'ls /dev/eink*'"

# If not rooted, this is expected
# App will work in standard display mode
```

---

## Next Steps After Successful Test

1. **Document your results**
   - Did e-ink device get detected?
   - Do buttons work?
   - Any crashes or errors?

2. **Share feedback**
   - Open issue on GitHub with results
   - Include device model and logs
   - Screenshots help!

3. **Root access (optional)**
   - For full e-ink control
   - Enables `/dev/eink-panel` access
   - Research root methods for your device

4. **Continue to Phase 2**
   - Xibo CMS integration
   - Content display
   - Real signage functionality

---

## Quick Reference Commands

```bash
# Essential commands for testing

# Check connection
adb devices

# Install app
adb install app/build/outputs/apk/debug/app-debug.apk

# Launch app
adb shell am start -n com.xibo.eink/.ui.activities.MainActivity

# View logs
adb logcat -s XiboEink:D EinkController:V

# Stop app
adb shell am force-stop com.xibo.eink

# Uninstall
adb uninstall com.xibo.eink

# Screenshot
adb shell screencap -p /sdcard/screenshot.png && adb pull /sdcard/screenshot.png

# Device info
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```

---

**Ready to start?** Follow the steps above and report your results! 🚀
