import 'package:flutter_test/flutter_test.dart';
import 'package:bhasha_setu_flutter/services/s2s/s2s_state_machine.dart';
import 'package:bhasha_setu_flutter/services/s2s/s2s_types.dart';

void main() {
  group('S2S Deterministic State Machine Tests', () {
    test('Initializes in IDLE state', () {
      final sm = S2SStateMachine();
      expect(sm.currentState, S2SState.idle);
      expect(sm.isIdle, isTrue);
    });

    test('Allows legal sequential conversational transitions', () {
      final sm = S2SStateMachine();

      // IDLE -> LISTENING
      expect(sm.transition(S2SState.listening), isTrue);
      expect(sm.isListening, isTrue);

      // LISTENING -> TRANSLATING
      expect(sm.transition(S2SState.translating), isTrue);

      // TRANSLATING -> SAFETY_CHECK
      expect(sm.transition(S2SState.safetyCheck), isTrue);

      // SAFETY_CHECK -> PLAYING
      expect(sm.transition(S2SState.playing), isTrue);
      expect(sm.isSpeaking, isTrue);

      // PLAYING -> IDLE
      expect(sm.transition(S2SState.idle), isTrue);
      expect(sm.isIdle, isTrue);
    });

    test('Rejects invalid transitions strictly', () {
      final sm = S2SStateMachine();

      // Cannot jump directly from IDLE to PLAYING
      expect(sm.transition(S2SState.playing), isFalse);
      expect(sm.currentState, S2SState.idle);

      // Cannot jump directly from IDLE to SAFETY_CHECK
      expect(sm.transition(S2SState.safetyCheck), isFalse);
      expect(sm.currentState, S2SState.idle);
    });
  });
}
