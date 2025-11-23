# Side-by-Side Code Comparison: Unity vs Flutter

This document provides a direct side-by-side comparison of the Unity C# code and its Flutter Dart equivalent.

## Table of Contents
1. [Constants Definition](#constants-definition)
2. [Class Structure](#class-structure)
3. [State Management](#state-management)
4. [Audio Recording](#audio-recording)
5. [Audio Playback](#audio-playback)
6. [Volume Detection](#volume-detection)
7. [State Transitions](#state-transitions)
8. [Idle State](#idle-state)
9. [Listen State](#listen-state)
10. [Talk State](#talk-state)

---

## Constants Definition

### Unity C# (GameConstants.cs)
```csharp
using UnityEngine;

public static class GameConstants {
    public const string PlayerTag = "Player";
    public const string GameControllerTag = "GameController";
    public const string MecanimTalk = "Talk";
    public const string MecanimListen = "Listen";
    public const string MecanimIdle = "Idle";
    public const string MicrophoneDeviceName = null;
    
    public const int IdleRecordingLength = 1;
    public const int RecordingLength = 5;
    public const int RecordingFrequency = 44100;
    public const int SampleDataLength = 1024;
    
    public const float SoundThreshold = 0.025f;
}
```

### Flutter Dart (game_constants.dart)
```dart
class GameConstants {
  static const String playerTag = "Player";
  static const String gameControllerTag = "GameController";
  static const String mecanimTalk = "Talk";
  static const String mecanimListen = "Listen";
  static const String mecanimIdle = "Idle";
  static const String? microphoneDeviceName = null;
  
  static const int idleRecordingLength = 1;
  static const int recordingLength = 5;
  static const int recordingFrequency = 44100;
  static const int sampleDataLength = 1024;
  
  static const double soundThreshold = 0.025;
}
```

**Key Differences:**
- C# uses `public static class`, Dart uses regular `class` with `static const`
- C# uses `float`, Dart uses `double`
- C# uses PascalCase, Dart uses camelCase
- Both use `null` for default microphone

---

## Class Structure

### Unity C# (GameController.cs)
```csharp
using UnityEngine;

enum PlayerState {
    Idle,
    Listening,
    Talking
}

[RequireComponent(typeof(AudioSource))]
public class GameController : MonoBehaviour {
    private Animator _playerAnimator;
    private PlayerState _playerState = PlayerState.Idle;
    private AudioSource _audioSource;
    private float[] _clipSampleData;
    
    void Start() {
        var playerGameObject = GameObject.FindGameObjectWithTag(GameConstants.PlayerTag);
        if(playerGameObject != null) {
            _playerAnimator = playerGameObject.GetComponent<Animator>();
        }
        _audioSource = GetComponent<AudioSource>();
        _clipSampleData = new float[GameConstants.SampleDataLength];
        Idle();
    }
    
    private void Update() {
        if(_playerState == PlayerState.Idle && IsVolumeAboveThresold()) {
            SwitchState();
        }
    }
}
```

### Flutter Dart (game_controller.dart)
```dart
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

enum PlayerState {
  idle,
  listening,
  talking,
}

class GameController extends ChangeNotifier {
  PlayerState _playerState = PlayerState.idle;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Timer? _stateTimer;
  Timer? _volumeCheckTimer;
  String? _currentRecordingPath;
  
  PlayerState get playerState => _playerState;
  
  GameController() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await idle();
  }
}
```

**Key Differences:**
- Unity: Inherits `MonoBehaviour`, uses Unity's component system
- Flutter: Extends `ChangeNotifier` for state management
- Unity: Has `Update()` called every frame automatically
- Flutter: Uses manual `Timer` for periodic checks
- Unity: Uses GameObject tags to find components
- Flutter: Direct object instantiation
- Dart uses lowercase enum values (`idle` vs `Idle`)

---

## State Management

### Unity C#
```csharp
private void Update() {
    if(_playerState == PlayerState.Idle && IsVolumeAboveThresold()) {
        SwitchState();
    }
}
```

### Flutter Dart
```dart
_volumeCheckTimer = Timer.periodic(
  const Duration(milliseconds: 100),
  (timer) async {
    if (_playerState == PlayerState.idle && await isVolumeAboveThreshold()) {
      timer.cancel();
      await switchState();
    }
  },
);

// Don't forget to notify listeners
notifyListeners();
```

**Key Differences:**
- Unity: Automatic frame updates via `Update()`
- Flutter: Manual timer with 100ms intervals
- Flutter: Must call `notifyListeners()` to update UI
- Flutter: Async/await pattern for operations

---

## Audio Recording

### Unity C# (Starting Recording)
```csharp
_audioSource.clip = Microphone.Start(
    GameConstants.MicrophoneDeviceName,  // null
    true,                                  // loop
    GameConstants.RecordingLength,        // 5 seconds
    GameConstants.RecordingFrequency     // 44100 Hz
);
```

### Flutter Dart (Starting Recording)
```dart
final directory = await getTemporaryDirectory();
_currentRecordingPath = '${directory.path}/user_recording.m4a';

await _audioRecorder.start(
  const RecordConfig(
    encoder: AudioEncoder.aacLc,
    sampleRate: GameConstants.recordingFrequency,  // 44100 Hz
    bitRate: 128000,
  ),
  path: _currentRecordingPath!,
);
```

**Key Differences:**
- Unity: Built-in `Microphone.Start()`, stores in `AudioSource.clip`
- Flutter: External package, requires file path
- Unity: Can specify loop and duration in start call
- Flutter: Duration managed separately with Timer
- Flutter: Must specify encoder and bitrate
- Flutter: Async operation

### Stopping Recording

**Unity:**
```csharp
Microphone.End(null);
```

**Flutter:**
```dart
await _audioRecorder.stop();
```

---

## Audio Playback

### Unity C#
```csharp
if(_audioSource.clip != null) {
    _audioSource.Play();
}
```

### Flutter Dart
```dart
if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
  await _audioPlayer.play(DeviceFileSource(_currentRecordingPath!));
}
```

**Key Differences:**
- Unity: Plays from memory (AudioClip)
- Flutter: Plays from file path
- Flutter: Must check file exists
- Flutter: Must specify source type (`DeviceFileSource`)

---

## Volume Detection

### Unity C# (Complex Sample Analysis)
```csharp
private bool IsVolumeAboveThresold() {
    if(_audioSource.clip == null) {
        return false;
    }
    
    // Read 1024 samples (about 80ms on 44kHz stereo)
    _audioSource.clip.GetData(_clipSampleData, _audioSource.timeSamples);
    
    var clipLoudness = 0f;
    foreach (var sample in _clipSampleData) {
        clipLoudness += Mathf.Abs(sample);
    }
    clipLoudness /= GameConstants.SampleDataLength;
    
    Debug.Log("Clip Loudness = " + clipLoudness);
    
    return clipLoudness > GameConstants.SoundThreshold;
}
```

### Flutter Dart (Simple Amplitude Check)
```dart
Future<bool> isVolumeAboveThreshold() async {
  try {
    if (!await _audioRecorder.isRecording()) {
      return false;
    }
    
    // Get amplitude directly from recorder
    final amplitude = await _audioRecorder.getAmplitude();
    final loudness = amplitude.current.abs();
    
    if (kDebugMode) {
      print("Clip Loudness = $loudness");
    }
    
    return loudness > GameConstants.soundThreshold;
  } catch (e) {
    if (kDebugMode) {
      print("Error checking volume: $e");
    }
    return false;
  }
}
```

**Key Differences:**
- Unity: Manual sample analysis, reads 1024 samples
- Flutter: Direct amplitude from recorder API
- Unity: Synchronous operation
- Flutter: Async operation with error handling
- Flutter: Much simpler implementation

---

## State Transitions

### Unity C# (Using Switch)
```csharp
private void SwitchState() {
    switch(_playerState) {
        case PlayerState.Idle:
            _playerState = PlayerState.Listening;
            Listen();
            break;
        
        case PlayerState.Listening:
            _playerState = PlayerState.Talking;
            Talk();
            break;
        
        case PlayerState.Talking:
            _playerState = PlayerState.Idle;
            Idle();
            break;
    }
}
```

### Flutter Dart (Using Switch with Async)
```dart
Future<void> switchState() async {
  switch (_playerState) {
    case PlayerState.idle:
      _playerState = PlayerState.listening;
      await listen();
      break;
    
    case PlayerState.listening:
      _playerState = PlayerState.talking;
      await talk();
      break;
    
    case PlayerState.talking:
      _playerState = PlayerState.idle;
      await idle();
      break;
  }
  notifyListeners();  // Update UI
}
```

**Key Differences:**
- Unity: Synchronous state changes
- Flutter: Async state changes with `await`
- Flutter: Must call `notifyListeners()` to update UI
- Same logic, different async pattern

---

## Idle State

### Unity C#
```csharp
private void Idle() {
    if (_playerAnimator != null) {
        _playerAnimator.SetTrigger(GameConstants.MecanimIdle);
        
        if (_audioSource.clip != null) {
            _audioSource.Stop();
            _audioSource.clip = null;
        }
        
        _audioSource.clip = Microphone.Start(
            GameConstants.MicrophoneDeviceName,
            true,
            GameConstants.IdleRecordingLength,
            GameConstants.RecordingFrequency
        );
    }
}
```

### Flutter Dart
```dart
Future<void> idle() async {
  if (kDebugMode) {
    print("Entering Idle state");
  }
  
  _stateTimer?.cancel();
  _volumeCheckTimer?.cancel();
  
  await _audioPlayer.stop();
  
  if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
    try {
      await File(_currentRecordingPath!).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting file: $e");
      }
    }
  }
  
  try {
    final directory = await getTemporaryDirectory();
    _currentRecordingPath = '${directory.path}/idle_recording.m4a';
    
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: GameConstants.recordingFrequency,
        bitRate: 128000,
      ),
      path: _currentRecordingPath!,
    );
    
    _volumeCheckTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) async {
        if (_playerState == PlayerState.idle && await isVolumeAboveThreshold()) {
          timer.cancel();
          await switchState();
        }
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print("Error starting idle recording: $e");
    }
  }
  
  notifyListeners();
}
```

**Key Differences:**
- Unity: Sets animator trigger
- Flutter: No animator (uses widget animation)
- Unity: Simple null assignment to clear clip
- Flutter: Must delete file from disk
- Flutter: Explicit timer management
- Flutter: More error handling
- Flutter: Must get temporary directory for file storage

---

## Listen State

### Unity C#
```csharp
private void Listen() {
    if(_playerAnimator != null) {
        _playerAnimator.SetTrigger(GameConstants.MecanimListen);
        
        _audioSource.clip = Microphone.Start(
            GameConstants.MicrophoneDeviceName,
            false,
            GameConstants.RecordingLength,
            GameConstants.RecordingFrequency
        );
        
        Invoke("SwitchState", GameConstants.RecordingLength);
    }
}
```

### Flutter Dart
```dart
Future<void> listen() async {
  if (kDebugMode) {
    print("Entering Listen state");
  }
  
  _volumeCheckTimer?.cancel();
  
  try {
    await _audioRecorder.stop();
    
    final directory = await getTemporaryDirectory();
    _currentRecordingPath = '${directory.path}/user_recording.m4a';
    
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: GameConstants.recordingFrequency,
        bitRate: 128000,
      ),
      path: _currentRecordingPath!,
    );
    
    _stateTimer = Timer(
      Duration(seconds: GameConstants.recordingLength),
      () async {
        await switchState();
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print("Error in listen state: $e");
    }
  }
  
  notifyListeners();
}
```

**Key Differences:**
- Unity: Uses `Invoke()` for delayed execution
- Flutter: Uses `Timer` for delayed execution
- Unity: String-based method name in Invoke
- Flutter: Direct callback function
- Flutter: Explicit error handling

---

## Talk State

### Unity C#
```csharp
private void Talk() {
    if (_playerAnimator != null) {
        _playerAnimator.SetTrigger(GameConstants.MecanimTalk);
        
        Microphone.End(null);
        
        if(_audioSource.clip != null) {
            _audioSource.Play();
        }
        
        Invoke("SwitchState", GameConstants.RecordingLength);
    }
}
```

### Flutter Dart
```dart
Future<void> talk() async {
  if (kDebugMode) {
    print("Entering Talk state");
  }
  
  try {
    await _audioRecorder.stop();
    
    if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(_currentRecordingPath!));
    }
    
    _stateTimer = Timer(
      Duration(seconds: GameConstants.recordingLength),
      () async {
        await switchState();
      },
    );
  } catch (e) {
    if (kDebugMode) {
      print("Error in talk state: $e");
    }
  }
  
  notifyListeners();
}
```

**Key Differences:**
- Unity: Sets animator trigger
- Flutter: UI responds to state via notifyListeners
- Unity: Stops recording via `Microphone.End()`
- Flutter: Stops recording via `_audioRecorder.stop()`
- Flutter: Must check file exists before playing
- Flutter: More error handling

---

## Summary

### Unity Strengths:
- Built-in audio system
- Automatic frame updates
- Visual animator system
- Simpler for game development

### Flutter Strengths:
- Cleaner async/await pattern
- Better error handling
- Cross-platform out of the box
- Modern UI framework
- Easier state management with ChangeNotifier

### Common Ground:
- Same state machine logic
- Same business rules
- Same constants and thresholds
- Similar overall architecture

The conversion demonstrates that game logic can be successfully translated between platforms, with the main differences being in framework APIs and patterns rather than core algorithms.
