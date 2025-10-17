#!/bin/bash
# install_and_test.sh - Script para instalar y probar AndroidXiboClientEink

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}AndroidXiboClientEink - Installation & Testing${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print colored messages
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Check if adb is available
if ! command -v adb &> /dev/null; then
    print_error "ADB not found. Please install Android SDK Platform-Tools"
    echo ""
    echo "Installation options:"
    echo "  1. Homebrew: brew install --cask android-platform-tools"
    echo "  2. Manual: Download from https://developer.android.com/studio/releases/platform-tools"
    exit 1
fi

print_status "ADB found: $(which adb)"

# Check for connected devices
echo ""
print_info "Checking for connected devices..."
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')

if [ "$DEVICE_COUNT" -eq 0 ]; then
    print_error "No devices connected"
    echo ""
    echo "Please:"
    echo "  1. Connect your tablet via USB"
    echo "  2. Enable USB debugging in Developer Options"
    echo "  3. Accept the USB debugging prompt on the device"
    echo "  4. Run this script again"
    exit 1
fi

print_status "Device connected: $DEVICE_COUNT device(s) found"
adb devices -l
echo ""

# Get device info
DEVICE_MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
DEVICE_MANUFACTURER=$(adb shell getprop ro.product.manufacturer | tr -d '\r')
ANDROID_VERSION=$(adb shell getprop ro.build.version.release | tr -d '\r')

print_info "Device: $DEVICE_MANUFACTURER $DEVICE_MODEL"
print_info "Android: $ANDROID_VERSION"
echo ""

# Check if Gradle wrapper exists
if [ ! -f "./gradlew" ]; then
    print_error "gradlew not found. Are you in the project root?"
    exit 1
fi

# Build APK
print_info "Building APK..."
./gradlew assembleDebug --quiet

if [ $? -eq 0 ]; then
    print_status "Build successful"
else
    print_error "Build failed"
    exit 1
fi

# Find APK
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"

if [ ! -f "$APK_PATH" ]; then
    print_error "APK not found at $APK_PATH"
    exit 1
fi

APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
print_status "APK ready: $APK_SIZE"
echo ""

# Uninstall old version if exists
print_info "Checking for previous installation..."
if adb shell pm list packages | grep -q "com.xibo.eink"; then
    print_info "Uninstalling old version..."
    adb uninstall com.xibo.eink
    print_status "Old version removed"
fi

# Install APK
print_info "Installing APK..."
adb install "$APK_PATH"

if [ $? -eq 0 ]; then
    print_status "Installation successful"
else
    print_error "Installation failed"
    exit 1
fi

echo ""
print_status "Application installed successfully!"
echo ""

# Launch app
print_info "Launching application..."
adb shell am start -n com.xibo.eink/.ui.activities.MainActivity

sleep 2

# Check if app is running
if adb shell pidof com.xibo.eink > /dev/null; then
    print_status "Application launched successfully"
else
    print_error "Application failed to launch"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Start logcat in background
LOGCAT_FILE="/tmp/xibo_eink_test.log"
print_info "Starting logcat (saving to $LOGCAT_FILE)..."
adb logcat -c  # Clear logcat
adb logcat -s EinkController:V XiboEink:D MainActivity:D > "$LOGCAT_FILE" &
LOGCAT_PID=$!

sleep 2

# Test 1: Check device detection
print_test "Test 1: E-ink device detection"
sleep 1
if grep -q "E-ink controller initialized" "$LOGCAT_FILE"; then
    print_status "E-ink device detected and initialized"
elif grep -q "Failed to open" "$LOGCAT_FILE"; then
    print_error "E-ink device not accessible"
    print_info "This may be normal - device might need root access"
else
    print_info "Checking device availability..."
fi

# Test 2: Check native library
print_test "Test 2: Native library loading"
if grep -q "eink_controller" "$LOGCAT_FILE" || adb shell pm list libraries | grep -q libeink; then
    print_status "Native library loaded"
else
    print_error "Native library not found"
fi

# Test 3: UI Elements
print_test "Test 3: UI rendering"
sleep 1
print_status "App is running (check device screen)"
echo ""

# Instructions for manual testing
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Manual Testing Instructions${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "Please perform these tests on the device:"
echo ""
echo "  1. Full Refresh Button"
echo "     - Tap 'Full Refresh'"
echo "     - Observe: Screen should redraw completely (~800ms)"
echo "     - Expected: Refresh count increments"
echo ""
echo "  2. Partial Refresh Button"
echo "     - Tap 'Partial Refresh' 5 times"
echo "     - Observe: Faster updates (~200ms)"
echo "     - Expected: Count increments each time"
echo ""
echo "  3. Clear Screen Button"
echo "     - Tap 'Clear Screen'"
echo "     - Observe: Screen resets"
echo "     - Expected: Clean white screen"
echo ""
echo "  4. Test Pattern Button"
echo "     - Tap 'Test Pattern' multiple times"
echo "     - Observe: Screen alternates black/white"
echo "     - Expected: Clear transitions without ghosting after 10 taps"
echo ""
echo -e "${YELLOW}========================================${NC}"
echo ""

print_info "Monitoring logs for 30 seconds..."
print_info "Press Ctrl+C to stop early"
echo ""

# Monitor for 30 seconds
sleep 30

# Stop logcat
kill $LOGCAT_PID 2>/dev/null

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Testing Complete${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

print_info "Log file saved to: $LOGCAT_FILE"
echo ""
echo "To view full logs:"
echo "  cat $LOGCAT_FILE"
echo ""
echo "To continue monitoring:"
echo "  adb logcat -s EinkController:V XiboEink:D"
echo ""

# Check for errors in log
ERROR_COUNT=$(grep -c "ERROR\|FATAL\|crash" "$LOGCAT_FILE" 2>/dev/null || echo 0)

if [ "$ERROR_COUNT" -gt 0 ]; then
    print_error "Found $ERROR_COUNT error(s) in logs"
    echo "Review the log file for details"
else
    print_status "No critical errors found in logs"
fi

echo ""
print_status "Testing session completed!"
echo ""
echo "Next steps:"
echo "  - Review manual test results"
echo "  - Check device behavior"
echo "  - Report issues on GitHub: https://github.com/NUbem000/AndroidXiboclienteink/issues"
echo ""
