import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../services/s2s/turn_controller.dart';
import '../../../services/s2s/s2s_types.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class SpeechToSpeechScreen extends StatefulWidget {
  const SpeechToSpeechScreen({super.key});

  @override
  State<SpeechToSpeechScreen> createState() => _SpeechToSpeechScreenState();
}

class _SpeechToSpeechScreenState extends State<SpeechToSpeechScreen> {
  final TurnController _controller = TurnController.instance;

  @override
  void initState() {
    super.initState();
    _controller.init();
    _controller.stateMachine.onStateChange((newState, oldState) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.abortCurrentTurn();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.stateMachine.currentState;
    final isListening = state == S2SState.listening;
    final isTranslating = state == S2SState.translating;
    final isPlaying = state == S2SState.playing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Top Status Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isListening ? Colors.red.shade50 : AppColors.surfaceSubtle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening ? Colors.red : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isListening
                          ? "Listening to ${_controller.currentSpeaker == SpeakerRole.speakerA ? 'Teacher' : 'Community'}..."
                          : (isTranslating ? "Translating on-device..." : (isPlaying ? "Speaking translation..." : "Ready for next speaker")),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isListening ? Colors.red.shade700 : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Silence Auto-Stop: 1400ms",
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Conversation Turns List
          Expanded(
            child: StreamBuilder<List<S2STurn>>(
              stream: _controller.historyStream,
              initialData: _controller.turnsHistory,
              builder: (context, snapshot) {
                final turns = snapshot.data ?? [];

                if (turns.isEmpty && _controller.liveTranscript.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.record_voice_over_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 16),
                          Text(
                            "Dual-Speaker Voice-to-Voice Conversation",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tap Speaker A (Teacher/Doctor in Hindi) or Speaker B (Community in Santali) to begin talking.",
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: turns.length + (_controller.liveTranscript.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show live interim bubble at the bottom if active
                    if (index == turns.length) {
                      return _buildLiveBubble();
                    }

                    final turn = turns[index];
                    return _buildTurnBubble(turn);
                  },
                );
              },
            ),
          ),

          // Bottom Dual-Speaker Controls
          _buildDualSpeakerControls(isListening),
        ],
      ),
    );
  }

  Widget _buildLiveBubble() {
    return Align(
      alignment: _controller.currentSpeaker == SpeakerRole.speakerA
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  "STREAMING LIVE...",
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _controller.liveTranscript,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnBubble(S2STurn turn) {
    final isSpeakerA = turn.speaker == SpeakerRole.speakerA;

    return Align(
      alignment: isSpeakerA ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSpeakerA ? Colors.white : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSpeakerA ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  turn.speakerName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSpeakerA ? AppColors.textSecondary : AppColors.primaryDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.primary),
                  onPressed: () {
                    TtsService.instance.speak(text: turn.targetText, langCode: turn.targetLang);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              turn.sourceText,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const Divider(color: AppColors.border, height: 16),
            Text(
              turn.targetText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            if (turn.roman != null && turn.roman!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                turn.roman!,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDualSpeakerControls(bool isListening) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Speaker A: Doctor / Teacher
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (isListening) {
                    _controller.finalizeTurn(reason: 'MANUAL_STOP');
                  } else {
                    _controller.startListeningTurn(SpeakerRole.speakerA);
                  }
                },
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isListening && _controller.currentSpeaker == SpeakerRole.speakerA)
                        ? Colors.red
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    (isListening && _controller.currentSpeaker == SpeakerRole.speakerA)
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Speaker A (Hindi)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),

          // Speaker B: Community Elder / Student
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (isListening) {
                    _controller.finalizeTurn(reason: 'MANUAL_STOP');
                  } else {
                    _controller.startListeningTurn(SpeakerRole.speakerB);
                  }
                },
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isListening && _controller.currentSpeaker == SpeakerRole.speakerB)
                        ? Colors.red
                        : AppColors.primaryDark,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    (isListening && _controller.currentSpeaker == SpeakerRole.speakerB)
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text("Speaker B (Santali)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
