class SubtitleCue {
  final int index;
  final double startSec;
  final double endSec;
  final String sourceText;
  final String translatedText;

  const SubtitleCue({
    required this.index,
    required this.startSec,
    required this.endSec,
    required this.sourceText,
    required this.translatedText,
  });
}

class SubtitleService {
  /// Format seconds into SubRip (.SRT) timestamp format: HH:MM:SS,mmm
  static String formatSrtTime(double sec) {
    final s = sec.clamp(0.0, double.infinity);
    final hrs = (s / 3600).floor();
    final mins = ((s % 3600) / 60).floor();
    final secs = (s % 60).floor();
    final ms = ((s % 1) * 1000).floor();
    return "${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')},${ms.toString().padLeft(3, '0')}";
  }

  /// Format seconds into WebVTT (.VTT) timestamp format: HH:MM:SS.mmm
  static String formatVttTime(double sec) {
    final s = sec.clamp(0.0, double.infinity);
    final hrs = (s / 3600).floor();
    final mins = ((s % 3600) / 60).floor();
    final secs = (s % 60).floor();
    final ms = ((s % 1) * 1000).floor();
    return "${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}";
  }

  /// Generate .SRT subtitle string
  static String generateSrt(List<SubtitleCue> cues, {bool bilingual = true}) {
    final buffer = StringBuffer();
    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln(cue.index);
      buffer.writeln("${formatSrtTime(cue.startSec)} --> ${formatSrtTime(cue.endSec)}");
      if (bilingual && cue.sourceText.isNotEmpty) {
        buffer.writeln(cue.sourceText);
      }
      buffer.writeln(cue.translatedText);
      buffer.writeln();
    }
    return buffer.toString();
  }

  /// Generate .VTT subtitle string
  static String generateVtt(List<SubtitleCue> cues, {bool bilingual = true}) {
    final buffer = StringBuffer();
    buffer.writeln("WEBVTT");
    buffer.writeln();
    for (int i = 0; i < cues.length; i++) {
      final cue = cues[i];
      buffer.writeln(cue.index);
      buffer.writeln("${formatVttTime(cue.startSec)} --> ${formatVttTime(cue.endSec)}");
      if (bilingual && cue.sourceText.isNotEmpty) {
        buffer.writeln(cue.sourceText);
      }
      buffer.writeln(cue.translatedText);
      buffer.writeln();
    }
    return buffer.toString();
  }
}
