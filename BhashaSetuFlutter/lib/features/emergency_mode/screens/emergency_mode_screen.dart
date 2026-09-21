import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({super.key});

  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen> {
  String? _copiedId;

  final List<Map<String, String>> emergencyPhrases = const [
    {
      'id': 'emg-1',
      'title': 'Call Ambulance / Hospital',
      'category': 'medical',
      'sat': 'ᱜᱚᱲᱚ ᱟᱹᱧ ᱯᱮ! ᱮᱢᱵᱩᱞᱮᱱᱥ ᱦᱚᱦᱚᱣᱟᱭ ᱯᱮ ᱾',
      'roman': 'Goro anj pe! Ambulance hohoway pe.',
      'hi': 'मदद करो! तुरंत एम्बुलेंस को बुलाओ।',
      'en': 'Help! Please call the ambulance immediately.',
    },
    {
      'id': 'emg-2',
      'title': 'Where Does it Hurt?',
      'category': 'vital',
      'sat': 'ᱚᱠᱟᱨᱮ ᱦᱟᱹᱥᱩ ᱮᱫ ᱢᱮᱭᱟ?',
      'roman': 'Okare hasu ed meya?',
      'hi': 'कहाँ दर्द हो रहा है? मुझे बताओ।',
      'en': 'Where does it hurt? Show me.',
    },
    {
      'id': 'emg-3',
      'title': 'Snakebite / Urgent Animal Attack',
      'category': 'trauma',
      'sat': 'ᱵᱤᱧ ᱜᱮᱨ ᱟᱠᱟᱫᱮᱭᱟ! ᱞᱚᱜᱚᱱ ᱦᱟᱥᱯᱟᱛᱟᱞ ᱤᱫᱤᱭᱮ ᱯᱮ ᱾',
      'roman': 'Biny ger akadeya! Logon haspatal idiye pe.',
      'hi': 'सांप ने काट लिया है! तुरंत अस्पताल ले चलो।',
      'en': 'A snake has bitten! Take them to hospital immediately.',
    },
    {
      'id': 'emg-4',
      'title': 'High Fever / Difficulty Breathing',
      'category': 'vital',
      'sat': 'ᱟᱹᱰᱤ ᱠᱮᱴᱮᱡ ᱨᱩᱣᱟᱹ ᱦᱮᱡ ᱟᱠᱟᱱᱟ ᱟᱨ ᱥᱟᱦᱮᱫ ᱦᱟᱹᱥᱩ ᱠᱟᱱᱟ ᱾',
      'roman': 'Adi ketej ruwa hej akana ar sahed hasu kana.',
      'hi': 'बहुत तेज़ बुखार है और सांस लेने में तकलीफ है।',
      'en': 'Severe high fever and difficulty breathing.',
    },
    {
      'id': 'emg-5',
      'title': 'Contaminated Water / Boil Water',
      'category': 'safety',
      'sat': 'ᱱᱚᱣᱟ ᱫᱟᱜ ᱟᱞᱚᱯᱮ ᱧᱩᱭᱟ, ᱞᱚᱜᱚᱱ ᱦᱮᱰᱮᱡ ᱫᱟᱜ ᱧᱩᱭ ᱯᱮ ᱾',
      'roman': 'Nowa daag alope nyuya, logon hedej daag nyuy pe.',
      'hi': 'यह पानी मत पियो, सिर्फ उबला हुआ पानी पियो।',
      'en': 'Do not drink this water, only drink boiled water.',
    },
    {
      'id': 'emg-6',
      'title': 'Flood / Extreme Weather Shelter',
      'category': 'safety',
      'sat': 'ᱵᱟᱹᱰ ᱫᱟᱜ ᱦᱤᱡᱩᱜ ᱠᱟᱱᱟ! ᱪᱮᱛᱟᱱ ᱴᱷᱟᱶ ᱛᱮ ᱪᱟᱞᱟᱜ ᱯᱮ ᱾',
      'roman': 'Bad daag hijug kana! Chetan thaon te chalag pe.',
      'hi': 'बाढ़ का पानी आ रहा है! ऊंचे स्थान पर चलें।',
      'en': 'Flood waters are coming! Move to higher ground immediately.',
    },
  ];

  void _handleCopy(String text, String id) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedId = id);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copiedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF2F2),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Emergency Banner
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFDE68A), size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          "RAPID EMERGENCY MODE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Emergency Tribal Communication Aid",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "One-touch high-contrast phrases for frontline health workers, disaster responders, and field officers.",
                                    style: TextStyle(
                                      color: Colors.red.shade100,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "NATIONAL EMERGENCY",
                                    style: TextStyle(
                                      color: Colors.red.shade100,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "112 / 108",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medical & Ethical Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFB45309), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Color(0xFF78350F), fontSize: 12.5, height: 1.45),
                                  children: [
                                    TextSpan(
                                      text: "Responsible Use & Medical Disclaimer: ",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                                    ),
                                    TextSpan(
                                      text: "This module provides verified translation assistance for acute situations. It does not substitute for trained clinical judgment or emergency medical personnel. Always contact local healthcare centers immediately during critical trauma or illness.",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Emergency Phrase Cards
                      ...emergencyPhrases.map((card) {
                        final id = card['id']!;
                        final isCopied = _copiedId == id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
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
                              // Card Top Bar
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Color(0xFFDC2626), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      card['title']!.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFB91C1C),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => TtsService.instance.speak(text: card['sat']!, langCode: 'sat'),
                                        icon: const Icon(Icons.volume_up_rounded, size: 15, color: Color(0xFFDC2626)),
                                        label: const Text("Santali Audio", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFEF2F2),
                                          side: const BorderSide(color: Color(0xFFFECACA)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => TtsService.instance.speak(text: card['hi']!, langCode: 'hin'),
                                        icon: const Icon(Icons.volume_up_rounded, size: 15, color: Color(0xFF475569)),
                                        label: const Text("Hindi Audio", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

                              // Santali Ol Chiki Script
                              Text(
                                card['sat']!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Phonetic: ${card['roman']}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Parallel Hindi & English
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 500;
                                  final hindiBox = Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "HINDI",
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF94A3B8),
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card['hi']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  final englishBox = Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "ENGLISH",
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF94A3B8),
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card['en']!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (isWide) {
                                    return Row(
                                      children: [
                                        Expanded(child: hindiBox),
                                        const SizedBox(width: 12),
                                        Expanded(child: englishBox),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        hindiBox,
                                        const SizedBox(height: 10),
                                        englishBox,
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 12),

                              // Quick Copy
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => _handleCopy("${card['sat']}\n${card['hi']}\n${card['en']}", id),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                          size: 14,
                                          color: isCopied ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isCopied ? "Copied" : "Copy All Text",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isCopied ? const Color(0xFF059669) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
}
