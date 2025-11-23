# Talking Tom Clone - Flutter Version

This is a Flutter conversion of the Unity C# Talking Tom clone application. The app listens to your voice, records it, and plays it back - just like the popular Talking Tom app!

## Original Unity Project

This project was originally built with Unity 2018.2 and C#. The Flutter conversion maintains the same core functionality while leveraging Flutter's cross-platform capabilities.

Original Unity tutorial: https://www.youtube.com/watch?v=VIJqTEn0kuA&list=PLQsObste68avW2QlR2HAmapkrCFMHhu_v

## Features

- **Voice Detection**: Automatically detects when you start speaking
- **Audio Recording**: Records your voice for 5 seconds
- **Playback**: Plays back your recorded voice
- **State Management**: Three states - Idle, Listening, and Talking
- **Cross-Platform**: Works on Android and iOS

## Technical Details

### Architecture

The Flutter app follows a clean architecture pattern:

1. **game_constants.dart**: Contains all game configuration constants (converted from Unity's GameConstants.cs)
2. **game_controller.dart**: Main game logic using Flutter's ChangeNotifier for state management (converted from Unity's GameController.cs)
3. **main.dart**: UI implementation using Flutter widgets with animations

### Key Conversions from Unity to Flutter

| Unity Component | Flutter Equivalent |
|----------------|-------------------|
| `GameObject` / `MonoBehaviour` | `ChangeNotifier` / `Widget` |
| `Animator` / Mecanim | `AnimationController` |
| `AudioSource` | `AudioPlayer` (audioplayers package) |
| `Microphone` class | `AudioRecorder` (record package) |
| `Update()` method | `Timer.periodic()` |
| `Invoke()` delay | `Timer()` |
| Unity Tags | Not needed in Flutter |

### Dependencies

The project uses the following Flutter packages:

- **provider**: State management
- **record**: Audio recording functionality
- **audioplayers**: Audio playback
- **permission_handler**: Handling microphone permissions
- **path_provider**: File system access for temporary storage

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode for mobile development
- A physical device or emulator with microphone support

## Installation

1. Clone the repository:
```bash
git clone https://github.com/FavourTy/Talking-Tom-Clone.git
cd Talking-Tom-Clone
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run
```

## Permissions

### Android

The app requires microphone permissions which are automatically requested at runtime. The permissions are declared in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS

Microphone permission is handled via `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your voice and play it back.</string>
```

## How It Works

1. **Idle State**: The app continuously monitors the microphone for sound input
2. **Listening State**: When sound above the threshold is detected, it starts recording for 5 seconds
3. **Talking State**: After recording, the app plays back your voice
4. **Loop**: Returns to Idle state and waits for the next input

## Project Structure

```
talking_tom_clone/
├── lib/
│   ├── main.dart              # App entry point and UI
│   ├── game_controller.dart   # Core game logic
│   └── game_constants.dart    # Configuration constants
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
├── pubspec.yaml              # Flutter dependencies
└── README_FLUTTER.md         # This file
```

## Customization

You can customize the following constants in `lib/game_constants.dart`:

- `recordingLength`: Duration of voice recording (default: 5 seconds)
- `soundThreshold`: Sensitivity for voice detection (default: 0.025)
- `recordingFrequency`: Audio quality (default: 44100 Hz)

## Differences from Unity Version

1. **Animation System**: Flutter uses `AnimationController` instead of Unity's Mecanim
2. **Audio Analysis**: Flutter's record package provides amplitude directly, whereas Unity requires sample data analysis
3. **State Management**: Uses Flutter's `ChangeNotifier` pattern instead of Unity's component lifecycle
4. **UI**: Complete UI redesign using Flutter's Material Design widgets
5. **Character**: Simple animated circle instead of Unity sprite/3D model (can be enhanced with custom animations)

## Future Enhancements

- Add custom character animations with Rive or Lottie
- Implement pitch shifting for funnier voice playback
- Add different character options
- Implement gesture interactions (tap, swipe)
- Add sound effects and background music

## Troubleshooting

### Microphone Permission Issues
- Ensure you've granted microphone permissions
- On iOS, check Settings > Privacy > Microphone
- On Android, check App Settings > Permissions

### No Sound Detected
- Try increasing the microphone volume
- Adjust `soundThreshold` in `game_constants.dart`
- Ensure you're using a physical device (emulators may have microphone issues)

### Build Issues
- Run `flutter clean` followed by `flutter pub get`
- Ensure your Flutter version is up to date: `flutter upgrade`

## Original Unity Project

The original Unity project files are still present in the repository:
- `Assets/Scripts/` - Original C# scripts
- `Assets/Animations/` - Unity animations
- `Assets/Scenes/` - Unity scenes
- `ProjectSettings/` - Unity project settings

## Contributing

Feel free to submit issues or pull requests to improve the Flutter version!

## License

This project maintains the same license as the original Unity version.

## Credits

- Original Unity implementation: [YouTube Tutorial](https://www.youtube.com/watch?v=VIJqTEn0kuA&list=PLQsObste68avW2QlR2HAmapkrCFMHhu_v)
- Flutter conversion: Converted from Unity C# to Flutter/Dart
- Character assets: [Tasty Characters - Forest Pack](https://assetstore.unity.com/packages/2d/characters/tasty-characters-free-forest-pack-108878)
