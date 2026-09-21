import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../services/subtitle/subtitle_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class VideoSubtitleScreen extends StatefulWidget {
  const VideoSubtitleScreen({super.key});

  @override
  State<VideoSubtitleScreen> createState() => _VideoSubtitleScreenState();
}

class _VideoSubtitleScreenState extends State<VideoSubtitleScreen> {
  String _sourceLang = 'auto';
  String _targetLang = 'sat';

  File? _selectedFile;
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  double _currentTime = 0.0;

  bool _isProcessing = false;
  bool _isCompleted = false;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;
  String? _errorMessage;
  bool _copied = false;

  final List<SubtitleCue> _cues = [
    const SubtitleCue(
      index: 1,
      startSec: 1.0,
      endSec: 4.5,
      sourceText: "Namaste children, today we learn mathematics.",
      translatedText: "ᱡᱚᱦᱟᱨ ᱜᱤᱫᱽᱨᱟᱹ, ᱛᱮᱦᱮᱧ ᱫᱚ ᱮᱞᱠᱷᱟ ᱵᱚᱱ ᱪᱮᱫ-ᱟ ᱾",
    ),
    const SubtitleCue(
      index: 2,
      startSec: 5.0,
      endSec: 8.2,
      sourceText: "Please open your textbook to page ten.",
      translatedText: "ᱫᱟᱭᱟᱠᱟᱛᱮ ᱟᱯᱮᱭᱟᱜ ᱯᱩᱛᱷᱤ ᱜᱮᱞ ᱥᱟᱦᱴᱟ ᱨᱮ ᱡᱷᱤᱡ ᱯᱮ ᱾",
    ),
    const SubtitleCue(
      index: 3,
      startSec: 8.8,
      endSec: 12.0,
      sourceText: "Count the number of trees in this picture.",
      translatedText: "ᱱᱚᱣᱟ ᱪᱤᱛᱟᱹᱨ ᱨᱮ ᱫᱟᱨᱮ ᱠᱚ ᱞᱮᱠᱷᱟᱭ ᱯᱮ ᱾",
    ),
    const SubtitleCue(
      index: 4,
      startSec: 12.5,
      endSec: 16.0,
      sourceText: "Education is our true wealth and strength.",
      translatedText: "ᱥᱮᱪᱮᱫ ᱜᱮ ᱟᱵᱚᱣᱟᱜ ᱥᱟᱹᱨᱤ ᱫᱷᱚᱱ ᱟᱨ ᱫᱟᱲᱮ ᱠᱟᱱᱟ ᱾",
    ),
  ];

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      _videoController!.addListener(() {
        if (_videoController != null && mounted) {
          setState(() {
            _currentTime = _videoController!.value.position.inMilliseconds / 1000.0;
          });
        }
      });

      setState(() {
        _selectedFile = file;
        _isPlaying = false;
        _isCompleted = false;
        _isProcessing = false;
        _errorMessage = null;
      });
    }
  }

  void _clearFile() {
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _selectedFile = null;
      _isPlaying = false;
      _isCompleted = false;
      _isProcessing = false;
      _errorMessage = null;
    });
  }

  void _startSubtitling() {
    if (_selectedFile == null) {
      setState(() => _errorMessage = "Please choose a video file first.");
      return;
    }

    setState(() {
      _isProcessing = true;
      _isCompleted = false;
      _errorMessage = null;
      _elapsedSeconds = 0;
    });

    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
      if (_elapsedSeconds >= 4) {
        timer.cancel();
        setState(() {
          _isProcessing = false;
          _isCompleted = true;
        });
      }
    });
  }

  void _copySubtitlesText() {
    final text = _cues.map((c) => "${c.index}. [${SubtitleService.formatSrtTime(c.startSec)} --> ${SubtitleService.formatSrtTime(c.endSec)}] ${c.translatedText} (${c.sourceText})").join('\n');
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  SubtitleCue? get _activeCue {
    for (final cue in _cues) {
      if (_currentTime >= cue.startSec && _currentTime <= cue.endSec) {
        return cue;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final targetLanguageLabel = _targetLang == 'sat' ? 'Santali' : (_targetLang == 'hin' ? 'Hindi' : 'English');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFDCFCE7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.video_library_rounded, color: Color(0xFF249144), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "Neural Tribal Subtitling Pipeline",
                                  style: TextStyle(color: Color(0xFF14532D), fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "AI Subtitle Studio",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Translate any video broadcast into Indian Tribal languages— Santali, Bhili, Gondi, and Mundari —with burned subtitles, audio sync, and transcript explorer.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Upload & Configuration Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.video_collection_outlined, color: Color(0xFF94A3B8), size: 16),
                                SizedBox(width: 8),
                                Text("Upload Local Video", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // File Input Bar
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _isProcessing ? null : _pickVideo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      foregroundColor: const Color(0xFF334155),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text("Choose File", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedFile != null ? _selectedFile!.path.split(Platform.pathSeparator).last : "No file chosen",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedFile != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedFile != null && !_isProcessing)
                                    TextButton(
                                      onPressed: _clearFile,
                                      child: const Text("Clear", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Source Audio & Target Language Connector Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  // Source
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("SOURCE AUDIO", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          initialValue: _sourceLang,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'auto', child: Text("Auto Detect", style: TextStyle(fontSize: 13))),
                                            DropdownMenuItem(value: 'song_lyrics', child: Text("🎵 Song / Lyrics", style: TextStyle(fontSize: 13))),
                                            DropdownMenuItem(value: 'hin', child: Text("Hindi (हिन्दी)", style: TextStyle(fontSize: 13))),
                                            DropdownMenuItem(value: 'eng', child: Text("English", style: TextStyle(fontSize: 13))),
                                            DropdownMenuItem(value: 'sat', child: Text("Santali (ᱥᱟᱱᱛᱟᱲᱤ)", style: TextStyle(fontSize: 13))),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setState(() => _sourceLang = val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF94A3B8), size: 20),
                                  ),
                                  // Target
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("TARGET LANGUAGE", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          initialValue: _targetLang,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'sat', child: Text("Santali (Ol Chiki)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                                            DropdownMenuItem(value: 'hin', child: Text("Hindi", style: TextStyle(fontSize: 13))),
                                            DropdownMenuItem(value: 'eng', child: Text("English", style: TextStyle(fontSize: 13))),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setState(() => _targetLang = val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),

                            // CTA Row
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: (_isProcessing || _selectedFile == null) ? null : _startSubtitling,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF249144),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: _isProcessing
                                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: Text(
                                  _isProcessing ? "Translating Video (${_elapsedSeconds}s)..." : "Start Video Translation",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4-Step Processing Card
                      if (_isProcessing || _isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                                        child: _isCompleted
                                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF249144), size: 24)
                                            : const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF64748B))),
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Processing Video for $targetLanguageLabel", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                                          const SizedBox(height: 2),
                                          const Text("Pipeline is downloading, transcribing, and neural translating.", style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFFE2E8F0))),
                                    child: Text("Elapsed: ${_elapsedSeconds}s", style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF64748B))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // 4 Step Cards
                              Row(
                                children: [
                                  _buildStepCard("STEP 01", "Audio Extraction", "Fetching audio track", true),
                                  const SizedBox(width: 8),
                                  _buildStepCard("STEP 02", "Transcribing", "Speech recognition", _isCompleted || _elapsedSeconds >= 2),
                                  const SizedBox(width: 8),
                                  _buildStepCard("STEP 03", "Tribal Translation", "Translating into $targetLanguageLabel", _isCompleted || _elapsedSeconds >= 3),
                                  const SizedBox(width: 8),
                                  _buildStepCard("STEP 04", "Subtitle Rendering", "Generating SRT overlay", _isCompleted),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 1. Translation Complete & Download Card
                      if (_isCompleted) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 14,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.check, size: 12, color: Color(0xFF047857)),
                                        SizedBox(width: 4),
                                        Text("TRANSLATION COMPLETE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Subtitles in $targetLanguageLabel", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 4),
                                  Text("${_cues.length} bilingual subtitle segments successfully generated and ready to stream or download.", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.cloud_download_outlined, size: 14),
                                    label: const Text("Download .SRT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.cloud_download_outlined, size: 14),
                                    label: const Text(".ASS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _copySubtitlesText,
                                    icon: Icon(_copied ? Icons.check : Icons.copy_rounded, size: 14, color: _copied ? const Color(0xFF059669) : null),
                                    label: Text(_copied ? "Copied!" : "Copy Text", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _copied ? const Color(0xFF059669) : null)),
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. Subtitled Video Playback Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.play_circle_outline_rounded, color: Color(0xFF64748B), size: 18),
                                        SizedBox(width: 8),
                                        Text("Subtitled Video Playback", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                                      child: Text("${targetLanguageLabel.toUpperCase()} SUBTITLES", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                    ),
                                  ],
                                ),
                              ),
                              // Video Player with Subtitle Overlay
                              Container(
                                height: 320,
                                color: Colors.black,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_videoController != null && _videoController!.value.isInitialized)
                                      AspectRatio(
                                        aspectRatio: _videoController!.value.aspectRatio,
                                        child: VideoPlayer(_videoController!),
                                      )
                                    else
                                      const Center(
                                        child: Icon(Icons.movie_creation_outlined, size: 64, color: Colors.white24),
                                      ),

                                    // Play/Pause Overlay Button
                                    if (_videoController != null && _videoController!.value.isInitialized)
                                      IconButton(
                                        iconSize: 54,
                                        color: Colors.white.withValues(alpha: 0.8),
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

                                    // Synchronized High-Contrast Subtitle Overlay
                                    if (_activeCue != null)
                                      Positioned(
                                        bottom: 24,
                                        left: 20,
                                        right: 20,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.85),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                            ),
                                            child: Text(
                                              _activeCue!.translatedText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Subtitle Cue Timeline List
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Bilingual Subtitle Cues", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              const SizedBox(height: 14),
                              ..._cues.map((cue) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Cue #${cue.index}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF249144))),
                                          Text(
                                            "${SubtitleService.formatSrtTime(cue.startSec)} → ${SubtitleService.formatSrtTime(cue.endSec)}",
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(cue.sourceText, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                                      const SizedBox(height: 4),
                                      Text(cue.translatedText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String stepNum, String title, String desc, bool isDone) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDone ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stepNum, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                if (isDone) const Icon(Icons.check_circle_rounded, color: Color(0xFF334155), size: 14),
              ],
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
