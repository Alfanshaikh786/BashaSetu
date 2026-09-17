/// S2S State Machine States matching React s2sStateMachine.ts exactly
enum S2SState {
  idle,
  listening,
  processingAudio,
  asrProcessing,
  translating,
  safetyCheck,
  ttsProcessing,
  playing,
  error,
  cancelled,
}

enum SpeakerRole {
  speakerA, // Person A (Teacher / Doctor)
  speakerB, // Person B (Tribal Student / Patient / Community Elder)
}

class S2STurn {
  final String id;
  final SpeakerRole speaker;
  final String speakerName;
  final String sourceLang;
  final String targetLang;
  final String sourceText;
  final String targetText;
  final String? roman;
  final double confidence;
  final DateTime timestamp;
  final bool isVerified;

  const S2STurn({
    required this.id,
    required this.speaker,
    required this.speakerName,
    required this.sourceLang,
    required this.targetLang,
    required this.sourceText,
    required this.targetText,
    this.roman,
    required this.confidence,
    required this.timestamp,
    required this.isVerified,
  });
}
