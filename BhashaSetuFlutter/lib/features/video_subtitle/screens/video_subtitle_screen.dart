import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/colors.dart';
import '../../../services/subtitle/subtitle_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class VideoSubtitleScreen extends StatefulWidget {
  const VideoSubtitleScreen({super.key});

  @override
  State<VideoSubtitleScreen> createState() => _VideoSubtitleScreenState();
}

class _VideoSubtitleScreenState extends State<VideoSubtitleScreen> {
  VideoPlayerController? _videoController;
  File? _videoFile;
  bool _isPlaying = false;

  final List<SubtitleCue> _cues = [
    const SubtitleCue(index: 1, startSec: 1.0, endSec: 4.5, sourceText: "Namaste children, today we learn mathematics.", translatedText: "ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ, ᱛᱮᱦᱮᱧ ᱫᱚ ᱮᱞᱠᱷᱟ ᱵᱚᱱ ᱪᱮᱫ-ᱟ ᱾"),
    const SubtitleCue(index: 2, startSec: 5.0, endSec: 8.2, sourceText: "Please open your textbook to page ten.", translatedText: "ᱫᱟᱭᱟᱠᱟᱛᱮ ᱟᱯᱮᱭᱟᱜ ᱯᱩᱛᱷᱤ ᱜᱮᱞ ᱥᱟᱦᱴᱟ ᱨᱮ ᱡᱷᱤᱡ ᱯᱮ ᱾"),
    const SubtitleCue(index: 3, startSec: 8.8, endSec: 12.0, sourceText: "Count the number of trees in this picture.", translatedText: "ᱱᱚᱣᱟ ᱪᱤᱛᱟᱹᱨ ᱨᱮ ᱫᱟᱨᱮ ᱠᱚ ᱞᱮᱠᱷᱟᱭ ᱯᱮ ᱾"),
  ];

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      setState(() {
        _videoFile = file;
        _isPlaying = false;
      });
    }
  }

  void _exportSrt() {
    final srt = SubtitleService.generateSrt(_cues);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Generated .SRT with ${_cues.length} cues!"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _exportVtt() {
    final vtt = SubtitleService.generateVtt(_cues);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Generated .VTT track with ${_cues.length} cues!"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.subtitles_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Video Subtitle Studio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text("Synchronized bilingual subtitles (.SRT & .VTT)", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Video Player Container
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: _videoController != null && _videoController!.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.white,
                          icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                          onPressed: () {
                            setState(() {
                              if (_videoController!.value.isPlaying) {
                                _videoController!.pause();
                                _isPlaying = false;
                              } else {
                                _videoController!.play();
                                _isPlaying = true;
                              }
                            });
                          },
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.video_file_rounded, size: 48, color: Colors.white54),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _pickVideo,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text("Select Lesson Video"),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Export Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportSrt,
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text("Export .SRT"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportVtt,
                    icon: const Icon(Icons.subtitles_rounded, size: 16, color: AppColors.primary),
                    label: const Text("Export .VTT"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subtitle Cue Timeline List
            const Text("Bilingual Subtitle Cues", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 12),

            ..._cues.map((cue) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cue #${cue.index}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(
                        "${SubtitleService.formatSrtTime(cue.startSec)} → ${SubtitleService.formatSrtTime(cue.endSec)}",
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(cue.sourceText, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(cue.translatedText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
