# Testing Guide - AndroidXiboClientEink

## Prerequisites

### Hardware
- E-ink tablet (Allwinner PB1041 or similar)
- USB cable
- Computer with ADB tools

### Software
- Android SDK Platform-Tools (for ADB)
- Either:
  - Android Studio (full IDE)
  - OR Just command-line tools

## Installation Methods

### Method 1: Automated Script (Recommended)

```bash
cd AndroidXiboclienteink
./scripts/install_and_test.sh
```

This script will:
1. Check ADB connection
2. Build the APK
3. Install on device
4. Launch the app
5. Monitor logs
6. Provide testing instructions

### Method 2: Manual Installation

#### Step 1: Install Platform Tools

**macOS (Homebrew):**
```bash
brew install --cask android-platform-tools
```

**Linux:**
```bash
sudo apt-get install android-tools-adb android-tools-fastboot
```

**Windows:**
Download from https://developer.android.com/studio/releases/platform-tools

#### Step 2: Connect Device

```bash
# Enable USB debugging on tablet:
# Settings > About > Tap "Build number" 7 times
# Settings > Developer Options > Enable "USB Debugging"

# Verify connection
adb devices

# Should show:
# List of devices attached
# XXXXXXXX    device
```

#### Step 3: Build APK

```bash
cd AndroidXiboclienteink

# Build debug APK
./gradlew assembleDebug

# APK location:
# app/build/outputs/apk/debug/app-debug.apk
```

#### Step 4: Install APK

```bash
# Install
adb install app/build/outputs/apk/debug/app-debug.apk

# Or reinstall if already installed
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

#### Step 5: Launch App

```bash
adb shell am start -n com.xibo.eink/.ui.activities.MainActivity
```

## Test Suite

### Test 1: Device Detection ✓

**Objective:** Verify e-ink device is detected

**Steps:**
1. Launch app
2. Check status text at top of screen

**Expected Results:**
- ✅ Status shows: "✓ E-ink display initialized"
- ✅ Device info displays:
  - Device: PB1041 (or your model)
  - Manufacturer: Allwinner
  - Android version
  - E-ink Available: Yes
  - Refresh Count: 0

**If Failed:**
- ⚠️ Shows: "✗ E-ink device not available"
- ℹ️ This is normal if `/dev/eink-panel` is not accessible
- ℹ️ App will run in standard display mode for testing

**Log Check:**
```bash
adb logcat -s EinkController:V | grep "initialized"
```

---

### Test 2: Full Refresh ⚡

**Objective:** Verify full screen refresh works

**Steps:**
1. Tap "Full Refresh" button
2. Observe screen behavior
3. Check refresh count

**Expected Results:**
- ✅ Screen performs complete redraw
- ✅ Takes ~500-1000ms
- ✅ No ghosting after refresh
- ✅ Refresh count increments to 1
- ✅ Toast shows: "Full refresh triggered"

**Observed Behavior:**
- Screen should flash/clear completely
- All previous ghost images removed
- Clean white background restored

**Log Check:**
```bash
adb logcat -s EinkController:D | grep "Full refresh"
```

**Pass Criteria:**
- [ ] Button responds to tap
- [ ] Screen visibly updates
- [ ] Counter increments
- [ ] No app crash

---

### Test 3: Partial Refresh 🔄

**Objective:** Verify partial refresh (fast update)

**Steps:**
1. Tap "Partial Refresh" button 10 times
2. Observe speed and behavior
3. Check refresh count

**Expected Results:**
- ✅ Each tap updates quickly (~100-300ms)
- ✅ Faster than full refresh
- ✅ May show slight ghosting after 3-4 taps
- ✅ Refresh count increments each time (1-10)
- ⚡ **Auto full refresh** triggers on 10th tap

**Observed Behavior:**
- Taps 1-9: Fast partial updates
- Tap 10: Automatic full refresh (clears ghosting)
- Counter resets to 0 after auto-refresh

**Log Check:**
```bash
adb logcat -s EinkController:D | grep "Partial refresh"
adb logcat -s EinkController:I | grep "Auto-triggering"
```

**Pass Criteria:**
- [ ] Faster than full refresh
- [ ] Counter works correctly
- [ ] Auto-refresh at count 10
- [ ] Ghosting clears after full refresh

---

### Test 4: Clear Screen 🧹

**Objective:** Verify screen clear functionality

**Steps:**
1. Tap "Test Pattern" a few times (create content)
2. Tap "Clear Screen" button
3. Observe result

**Expected Results:**
- ✅ Screen returns to clean white
- ✅ All content removed
- ✅ No ghosting
- ✅ Same effect as full refresh

**Observed Behavior:**
- Complete screen wipe
- Clean slate for new content

**Log Check:**
```bash
adb logcat -s EinkController:D | grep "Clearing screen"
```

**Pass Criteria:**
- [ ] Screen clears completely
- [ ] White background restored
- [ ] No errors in log

---

### Test 5: Test Pattern 🎨

**Objective:** Verify rendering and refresh quality

**Steps:**
1. Tap "Test Pattern" button 20 times
2. Observe alternating pattern
3. Check for ghosting

**Expected Results:**
- ✅ Alternates: White → Black → White → Black...
- ✅ Clear contrast
- ✅ No ghosting after 10 cycles (auto-refresh)
- ✅ Smooth transitions

**Observed Behavior:**
- Pattern: ⬜ ⬛ ⬜ ⬛ ⬜ ⬛...
- Cycles 1-9: May accumulate slight ghosting
- Cycle 10: Auto full refresh clears ghosting
- Continues with clean slate

**Log Check:**
```bash
adb logcat -s MainActivity:D
```

**Pass Criteria:**
- [ ] Pattern alternates correctly
- [ ] Visible on e-ink screen
- [ ] Auto-refresh prevents excessive ghosting
- [ ] No performance degradation

---

## Performance Tests

### Memory Usage 💾

```bash
# Check memory consumption
adb shell dumpsys meminfo com.xibo.eink

# Look for:
# - Native Heap: Should be < 20MB
# - Dalvik Heap: Should be < 30MB
# - Total PSS: Should be < 60MB
```

**Pass Criteria:**
- [ ] Memory stable (no leaks)
- [ ] Total < 100MB
- [ ] No OutOfMemory errors

---

### Battery Impact 🔋

```bash
# Check battery usage
adb shell dumpsys batterystats | grep com.xibo.eink

# Monitor for 5 minutes of use
```

**Expected:**
- Minimal battery drain
- E-ink only updates on button press
- Screen doesn't refresh continuously

**Pass Criteria:**
- [ ] No excessive battery drain
- [ ] CPU usage low when idle
- [ ] No wake locks held unnecessarily

---

### Stability Test 💪

**Objective:** Verify app doesn't crash

**Steps:**
1. Tap all buttons randomly for 5 minutes
2. Rotate device (if possible)
3. Lock/unlock screen
4. Return from home screen

**Pass Criteria:**
- [ ] No crashes
- [ ] No ANR (Application Not Responding)
- [ ] App resumes correctly
- [ ] Logs show no FATAL errors

---

## Log Analysis

### View All Logs
```bash
adb logcat -s EinkController:V XiboEink:D MainActivity:D
```

### Save Logs to File
```bash
adb logcat > xibo_eink_test.log
```

### Check for Errors
```bash
adb logcat -s AndroidRuntime:E
adb logcat | grep -i "error\|exception\|crash"
```

### Native Library Check
```bash
adb logcat -s DEBUG:I | grep eink_controller
```

---

## Troubleshooting

### App Won't Install
```bash
# Check APK signature
jarsigner -verify -verbose -certs app/build/outputs/apk/debug/app-debug.apk

# Force reinstall
adb install -r -d app/build/outputs/apk/debug/app-debug.apk
```

### Native Library Error
```bash
# Check if library exists
adb shell run-as com.xibo.eink ls lib/

# Should show: libeink_controller.so
```

### E-ink Device Not Found

**Check device nodes:**
```bash
adb shell "ls -l /dev/eink*"
adb shell "ls -l /dev/epd*"
```

**Possible paths:**
- `/dev/eink-panel`
- `/dev/epd`
- `/dev/fb0` (framebuffer)

**If not found:**
- Device may need root
- Driver may not be loaded
- Different device path needed

### Permissions Issues
```bash
# Check app permissions
adb shell dumpsys package com.xibo.eink | grep permission

# Grant specific permission if needed
adb shell pm grant com.xibo.eink android.permission.WRITE_EXTERNAL_STORAGE
```

---

## Test Results Template

Copy this template and fill in results:

```markdown
# Test Results - AndroidXiboClientEink

**Date:** YYYY-MM-DD
**Tester:** [Your Name]
**Device:** [Model] ([Manufacturer])
**Android Version:** X.Y
**App Version:** 0.1.0-alpha

## Device Information
- [ ] E-ink device detected: YES / NO
- [ ] Native library loaded: YES / NO
- [ ] Device path: /dev/eink-panel (or specify)

## Test Results

### Test 1: Device Detection
- Status: ✅ PASS / ❌ FAIL
- Notes: ________________________________

### Test 2: Full Refresh
- Status: ✅ PASS / ❌ FAIL
- Time: ~____ms
- Notes: ________________________________

### Test 3: Partial Refresh
- Status: ✅ PASS / ❌ FAIL
- Time: ~____ms
- Auto-refresh triggered: YES / NO
- Notes: ________________________________

### Test 4: Clear Screen
- Status: ✅ PASS / ❌ FAIL
- Notes: ________________________________

### Test 5: Test Pattern
- Status: ✅ PASS / ❌ FAIL
- Ghosting observed: YES / NO / MINIMAL
- Notes: ________________________________

## Performance
- Memory usage: ___ MB
- Battery impact: LOW / MEDIUM / HIGH
- Crashes: ___ (count)
- Errors in log: ___ (count)

## Overall Assessment
- [ ] Ready for production
- [ ] Needs minor fixes
- [ ] Needs major work
- [ ] Not functional

## Additional Notes
________________________________
________________________________

## Screenshots
[Attach screenshots if possible]

## Logs
[Attach relevant log excerpts]
```

---

## Next Steps After Testing

1. **Document Results**
   - Fill out test results template
   - Take screenshots
   - Save logs

2. **Report Issues**
   - Create GitHub issue if bugs found
   - Include device info and logs
   - Describe expected vs actual behavior

3. **Share Success**
   - Post results in Discussions
   - Help others with similar devices
   - Contribute improvements

4. **Continue Development**
   - Move to Phase 2 (Xibo integration)
   - Implement requested features
   - Optimize performance

---

**Questions?** Open an issue or discussion on GitHub!
