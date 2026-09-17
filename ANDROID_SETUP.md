# 🤖 BHASHA SETU — Android Studio & Flutter Setup Guide

> **Project Location**: `D:/BASHA SETU/BhashaSetuFlutter`  
> **Target SDK**: Android 14 (API Level 34)  
> **Minimum Supported SDK**: Android 5.0 (API Level 21 — Lollipop)  
> **Language & Framework**: Dart 3.x / Flutter 3.x  

---

## 1. Prerequisites & Environment Setup

To open, test, and build the Bhasha Setu Android application:

1. **Install Flutter SDK**:
   - Download the Flutter Windows SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows).
   - Extract to `C:\src\flutter` (or a directory of your choice).
   - Add `C:\src\flutter\bin` to your System Environment `PATH`.

2. **Verify Installation**:
   Open a terminal and run:
   ```bash
   flutter doctor
   ```
   Ensure the Android toolchain and connected devices are checked.

3. **Android Studio Setup**:
   - Install **Android Studio Hedgehog** (or newer).
   - Under **Plugins**, install:
     - `Flutter` plugin
     - `Dart` plugin
   - Under **SDK Manager**, install:
     - Android SDK Platform 34
     - Android SDK Build-Tools 34.0.0
     - Android SDK Command-line Tools

---

## 2. Opening the Project in Android Studio

1. Launch Android Studio.
2. Click **Open** and navigate to:
   ```
   D:\BASHA SETU\BhashaSetuFlutter
   ```
3. Open the root folder. Android Studio will automatically recognize the Flutter project and configure the Dart analysis server.

---

## 3. Installing Dependencies & Preparing Assets

In the terminal inside Android Studio (or PowerShell inside `D:\BASHA SETU\BhashaSetuFlutter`):

```bash
flutter pub get
```

This will resolve all dependencies declared in `pubspec.yaml`, including:
- `sqflite` (native SQLite)
- `flutter_riverpod` (reactive state management)
- `speech_to_text` (Android speech recognition)
- `flutter_tts` (Android speech synthesis)
- `google_mlkit_text_recognition` (on-device OCR)
- `video_player` (synchronized subtitle studio)
- `path_provider` (Android filesystem sandbox access)

---

## 4. Running the App on an Android Device or Emulator

### Using a Physical Android Phone (Recommended for Mic & Audio testing):
1. Enable **Developer Options** and **USB Debugging** on your Android phone.
2. Connect the phone via USB.
3. In Android Studio, select your phone from the device target dropdown.
4. Press the green **Run (Shift+F10)** button or run:
   ```bash
   flutter run
   ```

### Using an Android Studio Virtual Device (AVD):
1. Open **Virtual Device Manager** in Android Studio.
2. Create an emulator running Android 11+ with Play Store services.
3. Run `flutter run`.

---

## 5. Building the Production Release APK & App Bundle

### Release APK:
```bash
flutter build apk --release
```
The compiled APK will be generated at:
```
D:\BASHA SETU\BhashaSetuFlutter\build\app\outputs\flutter-apk\app-release.apk
```

### Google Play Store App Bundle (AAB):
```bash
flutter build appbundle --release
```
The compiled bundle will be generated at:
```
D:\BASHA SETU\BhashaSetuFlutter\build\app\outputs\bundle\release\app-release.aab
```

---

*Setup and build instructions complete.*
