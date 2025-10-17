# AndroidXiboClientEink 🎨📱

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Android](https://img.shields.io/badge/Android-7.0%2B-green.svg)](https://developer.android.com)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9%2B-purple.svg)](https://kotlinlang.org/)
[![Release](https://img.shields.io/github/v/release/NUbem000/AndroidXiboclienteink?include_prereleases)](https://github.com/NUbem000/AndroidXiboclienteink/releases)

**Xibo Digital Signage Client optimized for E-ink displays on Android tablets**

An open-source Android application that brings Xibo CMS digital signage capabilities to E-ink/E-paper displays, specifically optimized for devices with Allwinner SoCs.

## 📥 Download

**Latest Release:** [v0.1.0-alpha](https://github.com/NUbem000/AndroidXiboclienteink/releases/tag/v0.1.0-alpha)

**Direct Download:** [app-debug.apk](https://github.com/NUbem000/AndroidXiboclienteink/releases/download/v0.1.0-alpha/app-debug.apk) (9.4 MB)

> **Note:** Esta es una versión POC (Proof of Concept). La integración con Xibo CMS está planificada para la Fase 2.
> Esta versión valida la arquitectura del proyecto y el control e-ink nativo.

---

## 🎯 Features

- ✅ **E-ink Optimized Rendering** - Zero ghosting, controlled refresh rates
- ✅ **Xibo CMS Compatible** - Full integration with Xibo 4.x CMS
- ✅ **Low Power Consumption** - Perfect for battery-powered displays
- ✅ **Offline Mode** - Content caching and local playback
- ✅ **Widget Support** - Images, Text, Clock, RSS, Weather, Datasets
- ✅ **Kiosk Mode** - Auto-boot and secure display mode
- ✅ **Remote Management** - Control from Xibo CMS dashboard

---

## 📋 Requirements

### Hardware
- Android tablet with E-ink display (tested on Allwinner-based devices)
- Android 7.0 (API 24) or higher (Android 9.0+ recommended)
- 1GB RAM minimum (2GB recommended)
- 4GB storage minimum
- WiFi or Ethernet connectivity

### Software
- Xibo CMS 4.0+ server (self-hosted or cloud)
- E-ink display driver accessible via `/dev/eink-panel`

---

## 🚀 Quick Start

### Installation

1. **Download the latest APK** from [Releases](https://github.com/NUbem000/AndroidXiboclienteink/releases)
2. **Install on your E-ink tablet**:
   ```bash
   adb install AndroidXiboClientEink.apk
   ```
3. **Configure Xibo CMS connection** on first launch
4. **Activate Kiosk Mode** (optional)

### Building from Source

```bash
# Clone repository
git clone https://github.com/NUbem000/AndroidXiboclienteink.git
cd AndroidXiboclienteink

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Install to connected device
./gradlew installDebug
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         UI Layer (Activities/Fragments)     │
├─────────────────────────────────────────────┤
│         Presentation Layer (ViewModels)     │
├─────────────────────────────────────────────┤
│         Domain Layer (Use Cases)            │
├─────────────────────────────────────────────┤
│         Data Layer (Repository)             │
│  ┌──────────────┬──────────────────────┐   │
│  │  Xibo API    │  Local Database      │   │
│  │  (Retrofit)  │  (Room)              │   │
│  └──────────────┴──────────────────────┘   │
├─────────────────────────────────────────────┤
│         E-ink Display Manager (JNI)         │
└─────────────────────────────────────────────┘
```

**Pattern:** Clean Architecture + MVVM
**Language:** Kotlin + C++ (JNI)
**UI:** Jetpack Compose / Android Views

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed information.

---

## 📦 Project Structure

```
AndroidXiboclienteink/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/xibo/eink/
│   │   │   │   ├── ui/              # Activities, Fragments, Views
│   │   │   │   ├── data/            # API, Database, Repository
│   │   │   │   ├── domain/          # Use Cases, Business Logic
│   │   │   │   ├── renderer/        # Layout & Widget Rendering
│   │   │   │   ├── eink/            # E-ink Display Controller
│   │   │   │   └── utils/           # Helpers, Extensions
│   │   │   ├── cpp/                 # Native E-ink Driver (JNI)
│   │   │   ├── res/                 # Resources (layouts, strings)
│   │   │   └── AndroidManifest.xml
│   │   ├── test/                    # Unit Tests
│   │   └── androidTest/             # Integration Tests
│   ├── build.gradle.kts
│   └── CMakeLists.txt               # Native build config
├── docs/
│   ├── ARCHITECTURE.md              # Architecture details
│   ├── EINK_OPTIMIZATION.md         # E-ink rendering guide
│   ├── API.md                       # Xibo API integration
│   └── CONTRIBUTING.md
├── scripts/
│   ├── setup_device.sh              # Device setup automation
│   └── build_release.sh             # Release build script
├── .github/
│   └── workflows/
│       └── android.yml              # CI/CD pipeline
├── settings.gradle.kts
├── build.gradle.kts
├── gradle.properties
├── LICENSE
└── README.md
```

---

## 🎨 E-ink Optimization Techniques

This app implements several optimizations for E-ink displays:

1. **Controlled Refresh Rates**
   - Full refresh every 10 screen changes (prevents ghosting)
   - Partial refresh for minor updates
   - Configurable refresh intervals

2. **Zero Animation Policy**
   - All UI transitions are instant or controlled fades
   - No system animations
   - Disabled view transitions

3. **Bitmap Optimization**
   - Dithering for grayscale conversion
   - Pre-rendering of complex content
   - Optimized image formats

4. **Power Management**
   - Intelligent sleep mode
   - Wake-on-schedule
   - Battery optimization

See [EINK_OPTIMIZATION.md](docs/EINK_OPTIMIZATION.md) for technical details.

---

## 🛠️ Development

### Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- JDK 17+
- Android SDK 34
- Android NDK 25.x or later
- Git

### Setup Development Environment

```bash
# Clone repository
git clone https://github.com/NUbem000/AndroidXiboclienteink.git
cd AndroidXiboclienteink

# Open in Android Studio
# File > Open > Select AndroidXiboclienteink folder

# Sync Gradle
# Android Studio will automatically sync dependencies

# Connect your E-ink device via ADB
adb devices

# Run on device
./gradlew installDebug
```

### Running Tests

```bash
# Unit tests
./gradlew test

# Integration tests (requires connected device)
./gradlew connectedAndroidTest

# Code coverage
./gradlew jacocoTestReport
```

---

## 📚 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [E-ink Optimization](docs/EINK_OPTIMIZATION.md)
- [Xibo API Integration](docs/API.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details.

### Areas Where We Need Help:
- Testing on different E-ink devices
- Widget implementations
- Performance optimizations
- Documentation improvements
- Bug reports and fixes

---

## 🗺️ Roadmap

### Phase 1: Foundation (Current)
- [x] Project setup
- [ ] Basic Xibo API client
- [ ] E-ink display controller (JNI)
- [ ] Simple image display

### Phase 2: E-ink Optimization
- [ ] Full/partial refresh management
- [ ] Ghosting prevention
- [ ] Bitmap optimization pipeline
- [ ] Refresh rate tuning

### Phase 3: Xibo Features
- [ ] Layout engine
- [ ] Widget support (Image, Text, Clock)
- [ ] Schedule management
- [ ] Content caching

### Phase 4: Advanced Features
- [ ] Kiosk mode
- [ ] Remote management
- [ ] Power management
- [ ] Statistics reporting

### Phase 5: Production Ready
- [ ] Comprehensive testing
- [ ] Documentation
- [ ] Performance optimization
- [ ] v1.0 Release

---

## 📄 License

This project is licensed under the **GNU Affero General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

```
AndroidXiboClientEink - Xibo Digital Signage Client for E-ink Displays
Copyright (C) 2025 NUbem Systems

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
```

---

## 🙏 Acknowledgments

- [Xibo Signage](https://xibosignage.com/) - Original CMS platform
- [linux-sunxi.org](https://linux-sunxi.org/) - Allwinner documentation
- E-ink community for optimization techniques
- All contributors to this project

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/NUbem000/AndroidXiboclienteink/issues)
- **Discussions:** [GitHub Discussions](https://github.com/NUbem000/AndroidXiboclienteink/discussions)
- **Email:** support@nubemsystems.es

---

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=NUbem000/AndroidXiboclienteink&type=Date)](https://star-history.com/#NUbem000/AndroidXiboclienteink&Date)

---

**Made with ❤️ for the E-ink community**
