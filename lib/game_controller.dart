import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'game_constants.dart';

/// Player states corresponding to Unity's PlayerState enum
enum PlayerState {
  idle,
  listening,
  talking,
}

/// GameController converted from Unity C# to Flutter/Dart
/// This class manages the game logic for the Talking Tom clone
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
  
  /// Check if volume is above threshold
  /// Note: In Flutter, we use the record plugin's amplitude feature
  /// instead of analyzing sample data like Unity
  Future<bool> isVolumeAboveThreshold() async {
    try {
      if (!await _audioRecorder.isRecording()) {
        return false;
      }
      
      // Get amplitude from the recorder
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
  
  /// Switch between states: Idle -> Listening -> Talking -> Idle
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
    notifyListeners();
  }
  
  /// Idle state: Play idle animation and continuously monitor for sound
  Future<void> idle() async {
    if (kDebugMode) {
      print("Entering Idle state");
    }
    
    // Cancel any existing timers
    _stateTimer?.cancel();
    _volumeCheckTimer?.cancel();
    
    // Stop any playback
    await _audioPlayer.stop();
    
    // Delete previous recording
    if (_currentRecordingPath != null) {
      try {
        await File(_currentRecordingPath!).delete();
      } catch (e) {
        // Ignore errors if file doesn't exist
        if (kDebugMode) {
          print("Error deleting file: $e");
        }
      }
    }
    
    // Start recording for voice detection
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
      
      // Check volume periodically
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
  
  /// Listen state: Start recording user sound
  Future<void> listen() async {
    if (kDebugMode) {
      print("Entering Listen state");
    }
    
    // Cancel volume check timer
    _volumeCheckTimer?.cancel();
    
    try {
      // Stop previous recording
      await _audioRecorder.stop();
      
      // Start new recording
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
      
      // Transition to talking state after recording duration
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
  
  /// Talk state: Stop recording and play back the recorded sound
  Future<void> talk() async {
    if (kDebugMode) {
      print("Entering Talk state");
    }
    
    try {
      // Stop recording
      await _audioRecorder.stop();
      
      // Play recorded sound
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(_currentRecordingPath!));
      }
      
      // Transition to idle after playback duration
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
  
  @override
  void dispose() {
    _stateTimer?.cancel();
    _volumeCheckTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
