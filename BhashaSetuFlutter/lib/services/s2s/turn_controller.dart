import 'dart:async';
import 's2s_types.dart';
import 's2s_state_machine.dart';
import 'auto_stop_controller.dart';
import '../asr/asr_service.dart';
import '../tts/tts_service.dart';
import '../translation/translation_decision_engine.dart';

/// Central Turn Controller for Speech-to-Speech Translation
/// Directly replicates React turnController.ts with idempotent finalization & dual-speaker turns
class TurnController {
  static final TurnController instance = TurnController._internal();
  TurnController._internal();

  final S2SStateMachine stateMachine = S2SStateMachine();
  late final AutoStopController autoStopController;

  SpeakerRole currentSpeaker = SpeakerRole.speakerA;
  String speakerALang = 'hin'; // Doctor / Teacher
  String speakerBLang = 'sat'; // Tribal Elder / Patient / Student

  String liveTranscript = '';
  String liveTranslation = '';
  final List<S2STurn> turnsHistory = [];

  bool _isFinalizingMutex = false;
  final StreamController<List<S2STurn>> _historyStream = StreamController<List<S2STurn>>.broadcast();
  Stream<List<S2STurn>> get historyStream => _historyStream.stream;

  void init() {
    autoStopController = AutoStopController(
      autoStopSilenceMs: 1400, // 1400ms natural pause threshold
      initialSilenceTimeoutMs: 10000,
      onAutoStop: (reason) {
        finalizeTurn(reason: reason);
      },
    );
  }

  /// Starts listening for current speaker
  Future<void> startListeningTurn(SpeakerRole speaker) async {
    if (stateMachine.currentState != S2SState.idle) {
      await abortCurrentTurn();
    }

    currentSpeaker = speaker;
    liveTranscript = '';
    liveTranslation = '';
    _isFinalizingMutex = false;

    final srcLang = speaker == SpeakerRole.speakerA ? speakerALang : speakerBLang;

    stateMachine.transition(S2SState.listening);
    autoStopController.start();

    await AsrService.instance.startListening(
      langCode: srcLang,
      onSpeechStart: () {
        autoStopController.onSpeechActivity();
      },
      onResult: (words, isFinal, confidence) {
        liveTranscript = words;
        autoStopController.onSpeechActivity();

        if (isFinal) {
          finalizeTurn(reason: 'FINAL_ASR_TOKEN');
        } else {
          autoStopController.onSilenceDetected();
        }
      },
    );
  }

  /// Finalizes turn with idempotent lock
  Future<void> finalizeTurn({required String reason}) async {
    if (_isFinalizingMutex) return;
    _isFinalizingMutex = true;

    autoStopController.cancel();
    await AsrService.instance.stopListening();

    final text = liveTranscript.trim();
    if (text.isEmpty) {
      stateMachine.transition(S2SState.idle);
      _isFinalizingMutex = false;
      return;
    }

    // ── Transition: Translating ──
    stateMachine.transition(S2SState.translating);

    final srcLang = currentSpeaker == SpeakerRole.speakerA ? speakerALang : speakerBLang;
    final tgtLang = currentSpeaker == SpeakerRole.speakerA ? speakerBLang : speakerALang;

    final result = await TranslationDecisionEngine.instance.resolveTranslation(
      text: text,
      sourceLang: srcLang,
      targetLang: tgtLang,
    );

    liveTranslation = result.targetText;

    final turn = S2STurn(
      id: "turn_${DateTime.now().millisecondsSinceEpoch}",
      speaker: currentSpeaker,
      speakerName: currentSpeaker == SpeakerRole.speakerA ? "Teacher / Officer" : "Community Speaker",
      sourceLang: srcLang,
      targetLang: tgtLang,
      sourceText: text,
      targetText: result.targetText,
      roman: result.roman,
      confidence: result.confidence,
      timestamp: DateTime.now(),
      isVerified: result.isSuccess,
    );

    turnsHistory.add(turn);
    _historyStream.add(List.unmodifiable(turnsHistory));

    // ── Transition: Playing Audio ──
    if (result.isSuccess && result.targetText.isNotEmpty) {
      stateMachine.transition(S2SState.playing);
      await TtsService.instance.speak(
        text: result.targetText,
        langCode: tgtLang,
      );
    }

    stateMachine.transition(S2SState.idle);
    _isFinalizingMutex = false;
  }

  /// Abort turn
  Future<void> abortCurrentTurn() async {
    autoStopController.cancel();
    await AsrService.instance.cancelListening();
    await TtsService.instance.stop();
    stateMachine.reset();
    _isFinalizingMutex = false;
  }

  /// Clear all history
  void clearHistory() {
    turnsHistory.clear();
    _historyStream.add([]);
  }
}
