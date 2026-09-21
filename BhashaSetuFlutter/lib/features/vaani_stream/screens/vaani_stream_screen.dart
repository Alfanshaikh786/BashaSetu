import 'package:flutter/material.dart';
import '../../../services/tts/tts_service.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class LiveCaption {
  final String channel;
  final String lang;
  final String script;
  final String badge;
  final String text;
  final String langCode;

  const LiveCaption({
    required this.channel,
    required this.lang,
    required this.script,
    required this.badge,
    required this.text,
    required this.langCode,
  });
}

class VaaniStreamScreen extends StatefulWidget {
  const VaaniStreamScreen({super.key});

  @override
  State<VaaniStreamScreen> createState() => _VaaniStreamScreenState();
}

class _VaaniStreamScreenState extends State<VaaniStreamScreen> {
  final List<LiveCaption> _captions = const [
    LiveCaption(
      channel: 'Channel 01',
      lang: 'Santali',
      script: 'Ol Chiki',
      badge: 'SNT',
      text: 'ᱥᱟᱱᱟᱢ ᱫᱤᱥᱚᱢ ᱦᱚᱲ ᱠᱚ ᱡᱚᱦᱟᱨ • ᱛᱮᱦᱮᱧᱟᱜ ᱡᱟᱹᱛᱤᱭᱟᱹᱨᱤ ᱠᱟᱹᱢᱤᱦᱚᱨᱟ ᱨᱮ ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ᱾',
      langCode: 'sat',
    ),
    LiveCaption(
      channel: 'Channel 02',
      lang: 'Bhili',
      script: 'Devanagari',
      badge: 'BHI',
      text: 'सगळा भाइया-बेहना ने घणी बधाई • हमारो गाम मां विकास नी योजना लागू थई।',
      langCode: 'bhi',
    ),
    LiveCaption(
      channel: 'Channel 03',
      lang: 'Gondi',
      script: 'Central',
      badge: 'GON',
      text: 'सेवा जोहार! सगा समाज तुन बड़ादेव पेन ना कृपा मंतू • स्कूल अऊर अस्पताल बने मंता।',
      langCode: 'gon',
    ),
    LiveCaption(
      channel: 'Channel 04',
      lang: 'Mundari',
      script: 'Bani',
      badge: 'UNR',
      text: 'ᱟᱞᱮᱭᱟᱜ ᱦᱟᱛᱩ ᱨᱮ ᱥᱟᱹᱜᱩᱱ ᱫᱟᱨᱟᱢ • ᱵᱤᱨᱥᱟ ᱢᱩᱱᱰᱟ ᱣᱟᱜ ᱩᱞᱜᱩᱞᱟᱱ ᱫᱤᱥᱟᱹ ᱫᱚᱦᱚᱭ ᱢᱮ᱾',
      langCode: 'unr',
    ),
    LiveCaption(
      channel: 'Channel 05',
      lang: 'Kui',
      script: 'Odia',
      badge: 'KUI',
      text: 'ଜୋହାର • ଆମୋ ଗାଁ ରେ ଆପଣଙ୍କୁ ସ୍ୱାଗତ • ଧରଣୀ ପେନୁ ସବୁ ଜୀବନ ଦେଇଚି।',
      langCode: 'kui',
    ),
    LiveCaption(
      channel: 'Channel 06',
      lang: 'Garo',
      script: 'A·chik',
      badge: 'GRT',
      text: 'Mitela pilak manderangna • Wangala sal sokbaaha chingni a·dokona.',
      langCode: 'grt',
    ),
  ];

  String? _activeListeningChannel;

  void _listenChannel(LiveCaption cap) {
    if (_activeListeningChannel == cap.channel) {
      TtsService.instance.stop();
      setState(() => _activeListeningChannel = null);
    } else {
      setState(() => _activeListeningChannel = cap.channel);
      TtsService.instance.speak(text: cap.text, langCode: cap.langCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Simulcast Dark Container
                    _buildSimulcastBox(),
                  ],
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Live Multilingual Simulcast Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.radio_rounded, size: 14, color: Color(0xFFDC2626)),
              SizedBox(width: 6),
              Text(
                "Live Multilingual Simulcast",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          "Vaani Stream",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 10),

        // Underline Bar with Centered Green Accent
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 140, height: 2, color: const Color(0xFFE2E8F0)),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF86C498),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        const Text(
          "Live speech broadcast with simultaneous real-time multi-dialect neural caption stream.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulcastBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "LIVE BROADCAST FEED • INDEPENDENCE BROADCAST",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF87171),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.people_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 5),
                  Text(
                    "14,280 Listening",
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Broadcast Visual Screen
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background waveform / radio waves
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(24, (i) {
                    final heights = [20, 35, 60, 45, 80, 110, 75, 40, 90, 120, 70, 30, 50, 85, 100, 65, 45, 95, 115, 80, 50, 70, 40, 25];
                    return Container(
                      width: 3,
                      height: heights[i % heights.length].toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF249144).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),

                // Center Live Broadcast Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF249144)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.podcasts_rounded, color: Color(0xFF249144), size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Live Multi-Dialect Audio Stream Active",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Caption Wall Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.public_rounded, size: 16, color: Color(0xFF249144)),
                  SizedBox(width: 8),
                  Text(
                    "SIMULTANEOUS MULTI-DIALECT NEURAL CAPTIONS (6 CHANNELS)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCBD5E1),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Text(
                "Live latency: 340ms",
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 6-Channel Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final cards = _captions.map((cap) {
                final isListening = _activeListeningChannel == cap.channel;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isListening ? const Color(0xFF249144) : const Color(0xFF1E293B),
                      width: isListening ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${cap.channel} • ${cap.lang}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF249144),
                            ),
                          ),
                          Text(
                            cap.script,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cap.text,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE2E8F0),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () => _listenChannel(cap),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isListening ? const Color(0xFF249144) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isListening ? Icons.stop_rounded : Icons.volume_up_rounded,
                                size: 16,
                                color: isListening ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList();

              if (isWide) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 24) / 3, child: c)).toList(),
                );
              }
              return Column(
                children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
