# Quick Start Guide - Flutter Version

This guide will help you quickly get the Flutter version of Talking Tom Clone up and running.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Development Environment**
   - For Android: Android Studio with Android SDK
   - For iOS: Xcode (macOS only)

3. **Physical Device or Emulator**
   - The app requires microphone access, which works best on physical devices
   - Emulators may have limited microphone functionality

## Installation Steps

### 1. Navigate to the Project Directory

```bash
cd Talking-Tom-Clone
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will download all required packages including:
- `provider` - State management
- `record` - Audio recording
- `audioplayers` - Audio playback
- `permission_handler` - Permission handling
- `path_provider` - File system access

### 3. Verify Flutter Installation

```bash
flutter doctor
```

Ensure all required components are installed. Fix any issues reported.

### 4. Run the App

#### For Android:

```bash
# List available devices
flutter devices

# Run on connected Android device
flutter run

# Or specify device
flutter run -d <device-id>
```

#### For iOS (macOS only):

```bash
# List available devices
flutter devices

# Run on connected iOS device
flutter run

# Or run on iOS Simulator
flutter run -d "iPhone 14"
```

## First Time Setup

### Android

1. **Enable Developer Mode** on your Android device:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Enable "USB Debugging" in Developer Options

2. **Connect Device**:
   - Connect via USB
   - Authorize the computer when prompted

3. **Grant Permissions**:
   - When the app launches, grant microphone permission

### iOS

1. **Developer Account**:
   - You need an Apple Developer account (free or paid)
   
2. **Code Signing**:
   ```bash
   # Open iOS project in Xcode
   open ios/Runner.xcworkspace
   ```
   - Select a development team in Xcode
   - Configure signing

3. **Trust Developer**:
   - On device: Settings > General > VPN & Device Management
   - Trust your developer certificate

4. **Grant Permissions**:
   - When the app launches, grant microphone permission

## Using the App

1. **Launch**: The app starts in **Idle** state (blue circle)
2. **Speak**: Talk into your device's microphone
3. **Listen**: App switches to **Listening** state (green circle) and records for 5 seconds
4. **Playback**: App switches to **Talking** state (orange circle) and plays your voice back
5. **Repeat**: Returns to Idle and waits for your next input

## Troubleshooting

### Problem: "Microphone permission denied"

**Solution:**
- Grant microphone permission when prompted
- Or go to device Settings > Apps > Talking Tom Clone > Permissions > Microphone

### Problem: "No devices found"

**Solution:**
```bash
# Check connected devices
flutter devices

# For Android, ensure USB debugging is enabled
adb devices

# For iOS, ensure device is trusted
idevice_id -l
```

### Problem: "App crashes on launch"

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Problem: "No sound detected"

**Solution:**
- Speak louder or closer to the microphone
- Adjust `soundThreshold` in `lib/game_constants.dart`
- Ensure you're using a physical device (emulators may not support microphone)

### Problem: "Build fails"

**Solution:**
```bash
# Update Flutter
flutter upgrade

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run doctor to check for issues
flutter doctor -v
```

## Building for Release

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play)

```bash
# Build app bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build iOS app
flutter build ios --release

# Then use Xcode to archive and distribute
open ios/Runner.xcworkspace
```

## Development Tips

### Hot Reload

During development, use hot reload to see changes instantly:

- Press `r` in the terminal running `flutter run`
- Or use your IDE's hot reload button

### Hot Restart

For more significant changes:

- Press `R` in the terminal
- Or use your IDE's hot restart button

### Debug Mode

Run with debug output:

```bash
flutter run --verbose
```

### Performance Profiling

```bash
# Run with performance overlay
flutter run --profile
```

## Next Steps

- Read [README_FLUTTER.md](README_FLUTTER.md) for detailed documentation
- Check [CONVERSION_ANALYSIS.md](CONVERSION_ANALYSIS.md) to understand the Unity to Flutter conversion
- Customize constants in `lib/game_constants.dart`
- Add your own character animations

## Support

If you encounter issues:

1. Check [Flutter Documentation](https://flutter.dev/docs)
2. Review [Troubleshooting Guide](https://flutter.dev/docs/testing/debugging)
3. Open an issue on the GitHub repository

## Resources

- [Flutter Installation](https://flutter.dev/docs/get-started/install)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [pub.dev](https://pub.dev) - Flutter packages

Happy coding! 🚀
