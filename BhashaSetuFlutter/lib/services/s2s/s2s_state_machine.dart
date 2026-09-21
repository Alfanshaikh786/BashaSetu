import 'dart:async';
import 's2s_types.dart';

/// Deterministic S2S State Machine
/// Directly replicates React s2sStateMachine.ts with watchdog timeouts and strict transitions
class S2SStateMachine {
  S2SState _currentState = S2SState.idle;
  Timer? _watchdogTimer;

  final Set<void Function(S2SState newState, S2SState oldState)> _stateListeners = {};
  final Set<void Function(String errorMessage)> _errorListeners = {};

  // Maximum allowed duration in milliseconds for transient processing states
  static const Map<S2SState, int> stateTimeouts = {
    S2SState.listening: 30000,        // Max 30s single-turn speech
    S2SState.processingAudio: 8000,   // Max 8s audio buffer conversion
    S2SState.asrProcessing: 10000,    // Max 10s ASR network/inference
    S2SState.translating: 8000,       // Max 8s translation lookup
    S2SState.safetyCheck: 3000,       // Max 3s domain risk analysis
    S2SState.ttsProcessing: 5000,     // Max 5s voice synth initialization
    S2SState.playing: 15000,          // Max 15s audio utterance playback
  };

  // Valid deterministic transitions
  static const Map<S2SState, List<S2SState>> allowedTransitions = {
    S2SState.idle: [S2SState.listening, S2SState.error],
    S2SState.listening: [S2SState.processingAudio, S2SState.asrProcessing, S2SState.translating, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.processingAudio: [S2SState.asrProcessing, S2SState.translating, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.asrProcessing: [S2SState.translating, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.translating: [S2SState.safetyCheck, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.safetyCheck: [S2SState.ttsProcessing, S2SState.playing, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.ttsProcessing: [S2SState.playing, S2SState.cancelled, S2SState.error, S2SState.idle],
    S2SState.playing: [S2SState.idle, S2SState.listening, S2SState.cancelled, S2SState.error],
    S2SState.error: [S2SState.idle, S2SState.listening],
    S2SState.cancelled: [S2SState.idle, S2SState.listening],
  };

  S2SState get currentState => _currentState;
  bool get isIdle => _currentState == S2SState.idle;
  bool get isListening => _currentState == S2SState.listening;
  bool get isPlaying => _currentState == S2SState.playing;
  bool get isSpeaking => isPlaying;

  /// Transition to new state if valid
  bool transition(S2SState nextState) {
    if (_currentState == nextState) return true;

    final allowed = allowedTransitions[_currentState] ?? [];
    if (!allowed.contains(nextState)) {
      // Abort invalid transition
      return false;
    }

    _clearWatchdog();

    final oldState = _currentState;
    _currentState = nextState;

    // Set watchdog timer for transient processing states
    if (stateTimeouts.containsKey(nextState)) {
      _watchdogTimer = Timer(Duration(milliseconds: stateTimeouts[nextState]!), () {
        if (_currentState == nextState) {
          transition(S2SState.error);
          for (final listener in _errorListeners) {
            listener("Watchdog timeout in state: $nextState");
          }
        }
      });
    }

    // Notify listeners
    for (final listener in _stateListeners) {
      listener(nextState, oldState);
    }

    return true;
  }

  void onStateChange(void Function(S2SState newState, S2SState oldState) listener) {
    _stateListeners.add(listener);
  }

  void onError(void Function(String errorMessage) listener) {
    _errorListeners.add(listener);
  }

  void reset() {
    _clearWatchdog();
    _currentState = S2SState.idle;
  }

  void _clearWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
  }
}
