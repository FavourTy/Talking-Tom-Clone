# Architecture Diagram

## Flutter App Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     TalkingTomApp                           │
│                    (MaterialApp)                            │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ wraps with Provider
                          ▼
┌─────────────────────────────────────────────────────────────┐
│            ChangeNotifierProvider<GameController>           │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ provides state to
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                  TalkingTomHomePage                         │
│                   (StatefulWidget)                          │
│  ┌────────────────────────────────────────────────────┐     │
│  │         AnimationController                        │     │
│  │  - Handles character bounce animation              │     │
│  │  - Repeats when in Talking state                   │     │
│  └────────────────────────────────────────────────────┘     │
│  ┌────────────────────────────────────────────────────┐     │
│  │         Consumer<GameController>                   │     │
│  │  - Rebuilds UI when state changes                  │     │
│  │  - Displays current state visually                 │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ consumes state from
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    GameController                           │
│                  (extends ChangeNotifier)                   │
│                                                             │
│  State: PlayerState (enum)                                 │
│    - idle: Monitoring for voice                            │
│    - listening: Recording audio                            │
│    - talking: Playing back audio                           │
│                                                             │
│  Components:                                               │
│  ┌────────────────┐  ┌────────────────┐                   │
│  │ AudioRecorder  │  │  AudioPlayer   │                   │
│  │   (record pkg) │  │(audioplayers)  │                   │
│  └────────────────┘  └────────────────┘                   │
│  ┌────────────────┐  ┌────────────────┐                   │
│  │  _stateTimer   │  │_volumeCheckTimer│                  │
│  │  (transitions) │  │(voice detect)  │                   │
│  └────────────────┘  └────────────────┘                   │
│                                                             │
│  Methods:                                                  │
│    - idle()                                                │
│    - listen()                                              │
│    - talk()                                                │
│    - switchState()                                         │
│    - isVolumeAboveThreshold()                             │
└─────────────────────────────────────────────────────────────┘
```

## State Flow Diagram

```
                    ┌──────────────┐
                    │              │
                    │     IDLE     │◄─────────┐
                    │   (Monitoring) │         │
                    │              │         │
                    └──────┬───────┘         │
                           │                 │
                Voice      │                 │
              Detected     │                 │
            (threshold)    │                 │
                           │                 │
                           ▼                 │
                    ┌──────────────┐         │
                    │              │         │
                    │  LISTENING   │         │
                    │  (Recording) │         │
                    │              │         │
                    └──────┬───────┘         │
                           │                 │
                 After     │                 │
               5 seconds   │                 │
                           │                 │
                           ▼                 │
                    ┌──────────────┐         │
                    │              │         │
                    │   TALKING    │         │
                    │  (Playback)  │         │
                    │              │         │
                    └──────┬───────┘         │
                           │                 │
                 After     │                 │
               5 seconds   │                 │
                           │                 │
                           └─────────────────┘
```

## Audio Recording Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        IDLE STATE                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Start short recording (1 sec loop)                     │
│     ┌────────────────────────────────────────┐             │
│     │  await _audioRecorder.start(...)       │             │
│     │  path: temp/idle_recording.m4a         │             │
│     └────────────────────────────────────────┘             │
│                                                             │
│  2. Check volume every 100ms                               │
│     ┌────────────────────────────────────────┐             │
│     │  Timer.periodic(100ms) {               │             │
│     │    amplitude = getAmplitude()          │             │
│     │    if (amplitude > threshold)          │             │
│     │      → switch to LISTENING             │             │
│     │  }                                     │             │
│     └────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                           │
                Voice      │
              Detected     │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     LISTENING STATE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Stop previous recording                                │
│     ┌────────────────────────────────────────┐             │
│     │  await _audioRecorder.stop()           │             │
│     └────────────────────────────────────────┘             │
│                                                             │
│  2. Start new recording (5 sec)                            │
│     ┌────────────────────────────────────────┐             │
│     │  await _audioRecorder.start(...)       │             │
│     │  path: temp/user_recording.m4a         │             │
│     │  sampleRate: 44100 Hz                  │             │
│     └────────────────────────────────────────┘             │
│                                                             │
│  3. Set timer for 5 seconds                                │
│     ┌────────────────────────────────────────┐             │
│     │  Timer(5 sec, () {                     │             │
│     │    → switch to TALKING                 │             │
│     │  })                                    │             │
│     └────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
                           │
               After       │
             5 seconds     │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      TALKING STATE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Stop recording                                         │
│     ┌────────────────────────────────────────┐             │
│     │  await _audioRecorder.stop()           │             │
│     └────────────────────────────────────────┘             │
│                                                             │
│  2. Play recorded audio                                    │
│     ┌────────────────────────────────────────┐             │
│     │  if (file exists)                      │             │
│     │    await _audioPlayer.play(            │             │
│     │      DeviceFileSource(path)            │             │
│     │    )                                   │             │
│     └────────────────────────────────────────┘             │
│                                                             │
│  3. Set timer for 5 seconds                                │
│     ┌────────────────────────────────────────┐             │
│     │  Timer(5 sec, () {                     │             │
│     │    → switch to IDLE                    │             │
│     │  })                                    │             │
│     └────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

## UI Component Tree

```
Scaffold
  ├── AppBar
  │     └── Text("Talking Tom Clone")
  │
  └── Body: Consumer<GameController>
        └── Center
              └── Column
                    ├── Permission Warning (if not granted)
                    │     └── Card (red)
                    │           └── Text("Microphone permission required!")
                    │
                    ├── Character Display
                    │     └── ScaleTransition (animated)
                    │           └── Container (circle)
                    │                 ├── color: depends on state
                    │                 │    - Idle: blue
                    │                 │    - Listening: green
                    │                 │    - Talking: orange
                    │                 └── Icon: depends on state
                    │                      - Idle: sentiment_neutral
                    │                      - Listening: hearing
                    │                      - Talking: record_voice_over
                    │
                    ├── State Indicator
                    │     └── Card
                    │           └── Text (state name)
                    │
                    └── Instructions
                          └── Text("Speak to the character...")
```

## Dependency Graph

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter SDK                         │
│  - Material Design widgets                                 │
│  - Animation framework                                     │
│  - Foundation library                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
         ┌─────────────┴─────────────┬───────────────────────┐
         │                           │                       │
         ▼                           ▼                       ▼
┌─────────────────┐      ┌──────────────────┐    ┌─────────────────┐
│    provider     │      │      record      │    │  audioplayers   │
│  State mgmt     │      │   Recording      │    │    Playback     │
│   (v6.1.1)      │      │    (v5.0.4)      │    │    (v5.2.1)     │
└─────────────────┘      └──────────────────┘    └─────────────────┘
                                 │
                   ┌─────────────┴─────────────┐
                   │                           │
                   ▼                           ▼
         ┌─────────────────┐        ┌─────────────────┐
         │permission_handler│        │ path_provider   │
         │   Permissions   │        │   File paths    │
         │   (v11.0.1)     │        │    (v2.1.1)     │
         └─────────────────┘        └─────────────────┘
```

## Comparison with Unity Architecture

### Unity Architecture
```
┌─────────────────────────────────────────┐
│          Unity Scene                    │
│  ┌───────────────────────────────────┐  │
│  │  GameController GameObject        │  │
│  │  ├─ GameController.cs (script)    │  │
│  │  └─ AudioSource (component)       │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Player GameObject                │  │
│  │  ├─ Animator (component)          │  │
│  │  └─ SpriteRenderer (component)    │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Flutter Architecture
```
┌─────────────────────────────────────────┐
│          Widget Tree                    │
│  ┌───────────────────────────────────┐  │
│  │  MaterialApp                      │  │
│  │  └─ ChangeNotifierProvider        │  │
│  │     └─ TalkingTomHomePage         │  │
│  │        └─ Consumer                │  │
│  │           └─ UI Widgets           │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  GameController                   │  │
│  │  (separate business logic)        │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## File Structure

```
Talking-Tom-Clone/
│
├── Assets/                    # Unity files (original)
│   ├── Scripts/
│   │   ├── GameConstants.cs
│   │   └── GameController.cs
│   ├── Animations/
│   ├── Scenes/
│   └── Prefabs/
│
├── lib/                       # Flutter source code
│   ├── main.dart             # App entry & UI
│   ├── game_controller.dart  # Business logic
│   └── game_constants.dart   # Configuration
│
├── test/                      # Flutter tests
│   └── widget_test.dart
│
├── android/                   # Android config
│   └── app/src/main/
│       └── AndroidManifest.xml
│
├── ios/                       # iOS config
│   └── Runner/
│       └── Info.plist
│
├── pubspec.yaml              # Flutter dependencies
│
└── Documentation/
    ├── README.md             # Main readme
    ├── README_FLUTTER.md     # Flutter guide
    ├── QUICKSTART.md         # Quick start
    ├── CONVERSION_ANALYSIS.md
    ├── CODE_COMPARISON.md
    └── ARCHITECTURE.md       # This file
```

## Key Design Decisions

### 1. State Management: Provider Pattern
- **Why**: Simple, officially recommended by Flutter team
- **Alternative**: Bloc, Riverpod, GetX
- **Trade-off**: Less boilerplate vs less structure for large apps

### 2. Audio Recording: `record` package
- **Why**: Modern API, good platform support
- **Alternative**: flutter_sound, audio_recorder
- **Trade-off**: Simpler API vs fewer features

### 3. Audio Playback: `audioplayers` package
- **Why**: Popular, well-maintained
- **Alternative**: just_audio, assets_audio_player
- **Trade-off**: Simpler for basic use vs performance optimization

### 4. Animation: Built-in AnimationController
- **Why**: Native Flutter, good for simple animations
- **Alternative**: Rive, Lottie for complex character animations
- **Trade-off**: Simple code vs sophisticated visuals

### 5. File Storage: Temporary directory
- **Why**: Auto-cleanup, no persistent storage needed
- **Alternative**: Application documents directory
- **Trade-off**: Simpler permissions vs data persistence

## Performance Considerations

### Unity
- Update() called every frame (60 FPS)
- ~16.67ms per frame budget
- Native audio processing

### Flutter
- Timer checks every 100ms
- ~10 checks per second
- Plugin-based audio processing

### Optimization Opportunities
1. Adjust timer frequency based on state
2. Use audio streams instead of amplitude polling
3. Implement custom painter for character
4. Cache file paths
5. Use compute() for heavy processing

## Security & Privacy

### Permissions Required
- **Android**: RECORD_AUDIO, WRITE_EXTERNAL_STORAGE
- **iOS**: NSMicrophoneUsageDescription

### Data Handling
- Audio files stored in temporary directory
- Files deleted when returning to idle
- No network transmission
- No persistent storage

### Best Practices Implemented
- Runtime permission requests
- Error handling for denied permissions
- User-facing permission explanations
- Automatic cleanup of temporary files

## Future Enhancement Ideas

1. **Better Character Animation**
   - Use Rive or Lottie for professional animations
   - Lip-sync with audio amplitude
   - Multiple character options

2. **Audio Effects**
   - Pitch shifting
   - Speed variation
   - Echo/reverb effects

3. **Gesture Support**
   - Tap to trigger actions
   - Swipe to change characters
   - Pinch to zoom

4. **Recording Features**
   - Longer recording options
   - Save recordings
   - Share recordings

5. **Visual Enhancements**
   - 3D character rendering
   - Background themes
   - Particle effects

6. **Accessibility**
   - Voice-over support
   - High contrast mode
   - Haptic feedback
