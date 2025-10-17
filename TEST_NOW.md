# 🚀 Test NOW - Quick Start

**Want to test immediately? Follow these 3 steps:**

---

## ⚡ Step 1: Install ADB (2 minutes)

```bash
# Install Android Platform Tools
brew install --cask android-platform-tools

# Verify
adb version
```

**No Homebrew?** See [INSTALL_ADB.md](INSTALL_ADB.md) for alternatives.

---

## 📱 Step 2: Connect Tablet (1 minute)

1. **Enable USB Debugging on tablet:**
   - Settings → About tablet
   - Tap "Build number" 7 times
   - Settings → Developer options
   - Enable "USB debugging"

2. **Connect via USB cable**

3. **Accept prompt** on tablet: "Allow USB debugging?"

4. **Verify connection:**
   ```bash
   adb devices
   # Should show: NX3E0800019220W00019    device
   ```

---

## 🧪 Step 3: Run Tests (Automatic)

```bash
cd /Users/david/AndroidXiboclienteink

# Run automated test script
./scripts/install_and_test.sh
```

**The script will:**
- ✅ Build APK
- ✅ Install on tablet
- ✅ Launch app
- ✅ Monitor logs
- ✅ Guide you through tests

---

## 📋 Manual Tests (On Tablet Screen)

Once app launches, tap these buttons:

### Test 1: Full Refresh
- Tap → Observe screen flash → Check count

### Test 2: Partial Refresh (10x)
- Tap 10 times → See fast updates → Auto-refresh at 10

### Test 3: Clear Screen
- Tap → Screen clears to white

### Test 4: Test Pattern (20x)
- Tap rapidly → Alternates black/white → No ghosting

---

## ✅ Success Checklist

- [ ] App installed and launched
- [ ] UI is visible and responsive
- [ ] Buttons work when tapped
- [ ] No crashes
- [ ] Refresh counter increments

---

## 📊 Expected Results

### If E-ink Device Accessible:
- Status: "✓ E-ink display initialized"
- Native e-ink control works
- Refresh operations visible

### If E-ink Device NOT Accessible (Normal):
- Status: "✗ E-ink device not available"
- App runs in standard Android mode
- UI testing works fine
- Native e-ink needs root access

---

## 🐛 Problems?

### "adb: command not found"
```bash
brew install --cask android-platform-tools
```

### "device unauthorized"
- Check tablet screen for USB prompt
- Tap "Always allow"

### "device offline"
```bash
adb kill-server && adb start-server
```

### Build errors
```bash
./gradlew clean
./gradlew assembleDebug
```

**Still stuck?** See [TESTING_GUIDE.md](docs/TESTING_GUIDE.md)

---

## 📝 Report Results

After testing, please share:
1. Did it work? (Yes/No)
2. E-ink device detected? (Yes/No)
3. Any crashes or errors?
4. Screenshots (optional)

**Report on:** https://github.com/NUbem000/AndroidXiboclienteink/issues

---

## 🎯 That's It!

You now have a working POC of Xibo client for e-ink tablets!

**Next:** Phase 2 - Xibo CMS Integration

---

**Questions?** Open a GitHub issue or discussion.

**Success?** Star the repo! ⭐
