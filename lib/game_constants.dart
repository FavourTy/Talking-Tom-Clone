/// Game constants converted from Unity C# GameConstants.cs
class GameConstants {
  // Tags (not needed in Flutter but kept for reference)
  static const String playerTag = "Player";
  static const String gameControllerTag = "GameController";
  
  // Animation states
  static const String mecanimTalk = "Talk";
  static const String mecanimListen = "Listen";
  static const String mecanimIdle = "Idle";
  
  // Microphone device name (null for default device)
  static const String? microphoneDeviceName = null;
  
  // Recording lengths in seconds
  static const int idleRecordingLength = 1;
  static const int recordingLength = 5;
  
  // Recording frequency in Hz
  static const int recordingFrequency = 44100;
  
  // Sample data length for audio analysis
  static const int sampleDataLength = 1024;
  
  // Sound threshold for voice detection
  static const double soundThreshold = 0.025;
}
