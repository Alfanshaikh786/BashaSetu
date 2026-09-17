import 'package:flutter/material.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';

class EmergencyModeScreen extends StatelessWidget {
  const EmergencyModeScreen({super.key});

  final List<Map<String, String>> emergencyPhrases = const [
    {
      'title': 'Call Ambulance / Hospital',
      'category': 'Medical',
      'sat': 'ᱜᱚᱲᱚ ᱟᱹᱧ ᱯᱮ! ᱮᱢᱵᱩᱞᱮᱱᱥ ᱦᱚᱦᱚᱣᱟᱭ ᱯᱮ ᱾',
      'roman': 'Goro anj pe! Ambulance hohoway pe.',
      'hi': 'मदद करो! तुरंत एम्बुलेंस को बुलाओ।',
      'en': 'Help! Please call the ambulance immediately.',
    },
    {
      'title': 'Where Does it Hurt?',
      'category': 'Vital Signs',
      'sat': 'ᱚᱠᱟᱨᱮ ᱦᱟᱹᱥᱩ ᱮᱫ ᱢᱮᱭᱟ?',
      'roman': 'Okare hasu ed meya?',
      'hi': 'कहाँ दर्द हो रहा है? मुझे बताओ।',
      'en': 'Where does it hurt? Show me.',
    },
    {
      'title': 'Snakebite / Urgent Poison Attack',
      'category': 'Trauma',
      'sat': 'ᱵᱤᱧ ᱜᱮᱨ ᱟᱠᱟᱫᱮᱭᱟ! ᱞᱚᱜᱚᱱ ᱦᱟᱥᱯᱟᱛᱟᱞ ᱤᱫᱤᱭᱮ ᱯᱮ ᱾',
      'roman': 'Biny ger akadeya! Logon haspatal idiye pe.',
      'hi': 'सांप ने काट लिया है! तुरंत अस्पताल ले चलो।',
      'en': 'A snake has bitten! Take them to hospital immediately.',
    },
    {
      'title': 'Severe Fever & Difficulty Breathing',
      'category': 'Vital Signs',
      'sat': 'ᱟᱹᱰᱤ ᱠᱮᱴᱮᱡ ᱨᱩᱣᱟᱹ ᱦᱮᱡ ᱟᱠᱟᱱᱟ ᱟᱨ ᱥᱟᱦᱮᱫ ᱦᱟᱹᱥᱩ ᱠᱟᱱᱟ ᱾',
      'roman': 'Adi ketej ruwa hej akana ar sahed hasu kana.',
      'hi': 'बहुत तेज़ बुखार है और सांस लेने में तकलीफ है।',
      'en': 'Severe high fever and difficulty breathing.',
    },
    {
      'title': 'Contaminated Water / Boil Water',
      'category': 'Safety',
      'sat': 'ᱱᱚᱣᱟ ᱫᱟᱜ ᱟᱞᱚᱯᱮ ᱧᱩᱭᱟ, ᱞᱚᱜᱚᱱ ᱦᱮᱰᱮᱡ ᱫᱟᱜ ᱧᱩᱭ ᱯᱮ ᱾',
      'roman': 'Nowa daag alope nyuya, logon hedej daag nyuy pe.',
      'hi': 'यह पानी मत पियो, सिर्फ उबला हुआ पानी पियो।',
      'en': 'Do not drink this water, only drink boiled water.',
    },
    {
      'title': 'Flood / Extreme Weather Warning',
      'category': 'Safety',
      'sat': 'ᱵᱟᱹᱰ ᱫᱟᱜ ᱦᱤᱡᱩᱜ ᱠᱟᱱᱟ! ᱪᱮᱛᱟᱱ ᱴᱷᱟᱶ ᱛᱮ ᱪᱟᱞᱟᱜ ᱯᱮ ᱾',
      'roman': 'Bad daag hijug kana! Chetan thaon te chalag pe.',
      'hi': 'बाढ़ का पानी आ रहा है! ऊंचे स्थान पर चलें।',
      'en': 'Flood waters are coming! Move to higher ground immediately.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900.withValues(alpha: 0.05),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Emergency Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text("EMERGENCY MEDICAL TRIAGE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Rapid Offline Communication Board",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap speaker on any card to instantly communicate critical clinical instructions to tribal patients.",
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Emergency Cards List
            ...emergencyPhrases.map((card) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          card['category']!.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.red.shade700),
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: Colors.red.shade600),
                        icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                        onPressed: () {
                          TtsService.instance.speak(text: card['sat']!, langCode: 'sat');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card['title']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card['sat']!,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.red.shade900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pronunciation: ${card['roman']}",
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hindi: ${card['hi']}",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
