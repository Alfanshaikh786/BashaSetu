import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';
import '../../../services/translation/translation_decision_engine.dart';
import '../../../services/tts/tts_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Interactive Phone Card state
  String _sourceLang = 'eng';
  String _targetLang = 'sat';
  final TextEditingController _inputController = TextEditingController(text: "Where is the primary school?");
  String _translatedOutput = "ᱢᱟᱬᱟᱝ ᱟᱥᱲᱟ ᱫᱚ ᱚᱠᱟᱨᱮ ᱢᱮᱱᱟᱜ-ᱟ?";
  String _romanOutput = "Manang asra do okare menag-a?";
  bool _isTranslating = false;

  final List<Map<String, String>> _presets = [
    {
      'title': 'School Question',
      'src': 'Where is the primary school?',
      'tgt': 'ᱢᱟᱬᱟᱝ ᱟᱥᱲᱟ ᱫᱚ ᱚᱠᱟᱨᱮ ᱢᱮᱱᱟᱜ-ᱟ?',
      'roman': 'Manang asra do okare menag-a?'
    },
    {
      'title': 'Health Check',
      'src': 'Is your health good?',
      'tgt': 'ᱦᱚᱲᱢᱚ ᱵᱮᱥ ᱢᱮᱱᱟᱜ-ᱟ?',
      'roman': 'Hormo bes menag-a?'
    },
    {
      'title': 'Greetings',
      'src': 'Hello, how are you?',
      'tgt': 'ᱡᱚᱦᱟᱨ, ᱪᱮᱫ ᱞᱮᱠᱟ ᱢᱮᱱᱟᱢᱟ?',
      'roman': 'Johar, ched leka menama?'
    },
  ];

  Future<void> _handleTranslate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);
    final res = await TranslationDecisionEngine.instance.resolveTranslation(
      text: text,
      sourceLang: _sourceLang,
      targetLang: _targetLang,
    );

    setState(() {
      _translatedOutput = res.targetText;
      _romanOutput = res.roman ?? '';
      _isTranslating = false;
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _inputController.text = _translatedOutput;
      _translatedOutput = '';
      _romanOutput = '';
    });
    _handleTranslate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── HERO SECTION ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SIH Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          "SMART INDIA HACKATHON 2026 • 100% OFFLINE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  const Text(
                    "Bridge the Language Divide with Verified Tribal Translations",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    "An offline-first pedagogical and multi-modal ecosystem connecting migrant teachers, doctors, and frontline cadres directly with Santali, Gondi, Mundari, and Ho speaking communities.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/features/text-to-text');
                        },
                        icon: const Icon(Icons.translate_rounded, size: 18),
                        label: const Text("Start Translating"),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/features/speech-to-speech');
                        },
                        icon: const Icon(Icons.mic_rounded, size: 18, color: AppColors.primary),
                        label: const Text("Voice to Voice"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── INTERACTIVE PHONE CARD ──
                  _buildInteractivePhoneCard(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── CORE FEATURES GRID ──
            _buildFeaturesSection(),

            const SizedBox(height: 24),

            // ── HOW IT WORKS ──
            _buildHowItWorksSection(),

            const SizedBox(height: 32),

            // ── FOOTER ──
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePhoneCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Status Bar & Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text("Zero-Network Ready", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("Interactive Preview", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preset Chips
          SingleChildScrollView(
            scrollToDirection: Axis.horizontal,
            child: Row(
              children: _presets.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(p['title']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.veryLightGreen,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onPressed: () {
                      _inputController.text = p['src']!;
                      setState(() {
                        _translatedOutput = p['tgt']!;
                        _romanOutput = p['roman']!;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Language Selector Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_sourceLang == 'eng' ? "English" : "Santali (Ol Chiki)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  onPressed: _swapLanguages,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(_targetLang == 'sat' ? "Santali (Ol Chiki)" : "English", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Input Text Box
          TextField(
            controller: _inputController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: "Enter phrase to translate...",
              contentPadding: EdgeInsets.all(12),
            ),
            onSubmitted: (_) => _handleTranslate(),
          ),
          const SizedBox(height: 10),

          // Translate Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isTranslating ? null : _handleTranslate,
              child: _isTranslating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Translate Offline"),
            ),
          ),

          if (_translatedOutput.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Output Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TRANSLATION (VERIFIED)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        _translatedOutput,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                      if (_romanOutput.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "Pronunciation: $_romanOutput",
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                  onPressed: () {
                    TtsService.instance.speak(text: _translatedOutput, langCode: _targetLang);
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {'title': 'Text-to-Text', 'desc': 'Multidirectional translation across Santali, Mundari, Ho, Hindi & English.', 'icon': Icons.translate_rounded, 'route': '/features/text-to-text'},
      {'title': 'Voice-to-Voice (S2S)', 'desc': 'Real-time dual speaker conversation with automatic silence stop.', 'icon': Icons.record_voice_over_rounded, 'route': '/features/speech-to-speech'},
      {'title': 'Document OCR', 'desc': 'Extract and translate printed textbook notices from camera scans.', 'icon': Icons.document_scanner_rounded, 'route': '/features/ocr'},
      {'title': 'Learning Studio', 'desc': 'Interactive 3D flashcards, printable A4 worksheets, and quizzes.', 'icon': Icons.school_rounded, 'route': '/features/learning-studio'},
      {'title': 'Video Subtitles', 'desc': 'Synchronized bilingual caption generator with SRT & VTT exports.', 'icon': Icons.subtitles_rounded, 'route': '/features/video-subtitle'},
      {'title': 'Emergency Mode', 'desc': 'Rapid offline medical triage cards for snakebites, fever, and trauma.', 'icon': Icons.emergency_rounded, 'route': '/emergency-mode'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Core AI & Pedagogical Capabilities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text("Engineered for zero-network rural classrooms and frontline health posts.", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollExceptionScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, i) {
              final f = features[i];
              return InkWell(
                onTap: () => Navigator.pushNamed(context, f['route'] as String),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(f['icon'] as IconData, color: AppColors.primary, size: 22),
                      ),
                      const Spacer(),
                      Text(f['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(f['desc'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    final steps = [
      {'step': '01', 'title': 'Select Language & Script', 'desc': 'Choose from Santali Ol Chiki, Mundari, Ho, Hindi, or English.'},
      {'step': '02', 'title': 'Instant Local Translation', 'desc': 'Queries the local 6,780 parallel database in under 20ms with 0 bytes transmitted.'},
      {'step': '03', 'title': 'Listen & Teach Offline', 'desc': 'Audio synthesis pronounces tribal phonetics accurately for children and community elders.'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("How Bhasha Setu Works", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          ...steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(s['step']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(s['desc']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
