import 'package:flutter_test/flutter_test.dart';
import 'package:talking_tom_clone/game_constants.dart';
import 'package:talking_tom_clone/game_controller.dart';

void main() {
  group('GameConstants Tests', () {
    test('Constants have correct values', () {
      expect(GameConstants.recordingLength, equals(5));
      expect(GameConstants.idleRecordingLength, equals(1));
      expect(GameConstants.recordingFrequency, equals(44100));
      expect(GameConstants.soundThreshold, equals(0.025));
      expect(GameConstants.sampleDataLength, equals(1024));
    });

    test('Animation state names are correct', () {
      expect(GameConstants.mecanimTalk, equals("Talk"));
      expect(GameConstants.mecanimListen, equals("Listen"));
      expect(GameConstants.mecanimIdle, equals("Idle"));
    });
  });

  group('GameController Tests', () {
    test('GameController initializes with Idle state', () {
      final controller = GameController();
      expect(controller.playerState, equals(PlayerState.idle));
      controller.dispose();
    });

    test('PlayerState enum has correct values', () {
      expect(PlayerState.values.length, equals(3));
      expect(PlayerState.values, contains(PlayerState.idle));
      expect(PlayerState.values, contains(PlayerState.listening));
      expect(PlayerState.values, contains(PlayerState.talking));
    });
  });
}
