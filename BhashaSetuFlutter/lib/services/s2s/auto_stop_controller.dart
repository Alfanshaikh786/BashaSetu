import 'dart:async';

/// Silence Auto-Stop Controller
/// Faithfully reproduces React autoStopController.ts
class AutoStopController {
  final int autoStopSilenceMs;       // Default: 1400ms (natural pause) to 2000ms
  final int initialSilenceTimeoutMs; // Default: 10000ms
  final int minSpeechDurationMs;     // Default: 300ms

  final void Function(String reason)? onAutoStop;
  final void Function(int remainingMs)? onCountdown;

  Timer? _initialTimer;
  Timer? _silenceTimer;

  bool _speechHasStarted = false;
  bool _speechCurrentlyActive = false;
  int _speechStartTimestamp = 0;
  bool _hasStopped = false;

  AutoStopController({
    this.autoStopSilenceMs = 1400,
    this.initialSilenceTimeoutMs = 10000,
    this.minSpeechDurationMs = 300,
    this.onAutoStop,
    this.onCountdown,
  });

  /// Starts monitoring for speech and silence
  void start() {
    cancel();
    _speechHasStarted = false;
    _speechCurrentlyActive = false;
    _speechStartTimestamp = 0;
    _hasStopped = false;

    // Initial timeout: if user never speaks within 10s, auto-stop
    _initialTimer = Timer(Duration(milliseconds: initialSilenceTimeoutMs), () {
      if (!_hasStopped && !_speechHasStarted) {
        _triggerStop('INITIAL_SILENCE_TIMEOUT');
      }
    });
  }

  /// Called by ASR/VAD whenever acoustic speech activity is detected
  void onSpeechActivity() {
    if (_hasStopped) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (!_speechHasStarted) {
      _speechHasStarted = true;
      _speechStartTimestamp = now;
      _initialTimer?.cancel();
    }

    _speechCurrentlyActive = true;
    _silenceTimer?.cancel();
  }

  /// Called by ASR/VAD whenever interim speech stops / silence begins
  void onSilenceDetected() {
    if (_hasStopped || !_speechHasStarted) return;

    _speechCurrentlyActive = false;
    _silenceTimer?.cancel();

    _silenceTimer = Timer(Duration(milliseconds: autoStopSilenceMs), () {
      if (!_hasStopped && !_speechCurrentlyActive) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _speechStartTimestamp >= minSpeechDurationMs) {
          _triggerStop('SILENCE_AFTER_SPEECH');
        }
      }
    });
  }

  void _triggerStop(String reason) {
    if (_hasStopped) return;
    _hasStopped = true;
    cancel();
    onAutoStop?.call(reason);
  }

  /// Cancels all pending timers
  void cancel() {
    _initialTimer?.cancel();
    _silenceTimer?.cancel();
    _initialTimer = null;
    _silenceTimer = null;
  }
}
