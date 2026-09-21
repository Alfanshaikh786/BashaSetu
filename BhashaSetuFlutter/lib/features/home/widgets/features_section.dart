import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FBF7),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          // Header Emblem (Book Icon with soft disc)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD5E8D5)),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF238B45),
              size: 26,
            ),
          ),
          const SizedBox(height: 12),

          // Title
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17212B),
                fontFamily: 'serif',
              ),
              children: [
                TextSpan(text: "Our "),
                TextSpan(
                  text: "Features",
                  style: TextStyle(color: Color(0xFF238B45)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Green Accent Line
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF238B45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          const Text(
            "Discover the powerful capabilities of our translation platform.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),

          // Cursive Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5EA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5E8D5)),
            ),
            child: const Text(
              "Different Languages A Brighter Tomorrow",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF17212B),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 6 Feature Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final cards = _buildCards(context);
              if (isWide) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 20) / 2, child: c)).toList(),
                );
              }
              return Column(
                children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: c)).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // Bottom Right Cursive Tagline
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Languages Connect People",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17212B),
                  ),
                ),
                Container(
                  width: 100,
                  height: 2,
                  margin: const EdgeInsets.only(top: 2),
                  color: const Color(0xFF238B45).withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    return [
      _FeatureCard(
        title: "Text to Text Translation",
        description: "Instantly translate written text between languages with our AI-powered translation technology.",
        route: "/features/text-to-text",
        badgeIcon: _buildBadge(
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF238B45), width: 1.5),
                  ),
                  child: const Text("A", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF17212B))),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF238B45), width: 1.5),
                  ),
                  child: const Text("अ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF17212B))),
                ),
              ),
            ],
          ),
        ),
      ),
      _FeatureCard(
        title: "OCR",
        description: "Extract and translate text from images or documents.",
        route: "/features/ocr",
        badgeIcon: _buildBadge(
          Container(
            width: 32,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF238B45), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("OCR", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF238B45))),
                const SizedBox(height: 2),
                Container(width: 18, height: 1.5, color: const Color(0xFF238B45)),
                const SizedBox(height: 2),
                Container(width: 14, height: 1.5, color: const Color(0xFF238B45)),
              ],
            ),
          ),
        ),
      ),
      _FeatureCard(
        title: "Speech to Text",
        description: "Convert spoken words into translated text in real time.",
        route: "/features/speech-to-text",
        badgeIcon: _buildBadge(
          const Icon(Icons.mic_rounded, color: Color(0xFF238B45), size: 30),
        ),
      ),
      _FeatureCard(
        title: "Voice to Voice",
        description: "Real-time voice-to-voice speech translation into Santali, Mundari, and Bhili.",
        route: "/features/speech-to-speech",
        badgeIcon: _buildBadge(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.mic_none_rounded, color: Color(0xFF238B45), size: 16),
              SizedBox(width: 2),
              Icon(Icons.graphic_eq_rounded, color: Color(0xFF238B45), size: 18),
              SizedBox(width: 2),
              Icon(Icons.mic_none_rounded, color: Color(0xFF238B45), size: 16),
            ],
          ),
        ),
      ),
      _FeatureCard(
        title: "Text to Speech",
        description: "Convert written text into natural-sounding audio in tribal languages.",
        route: "/features/text-to-speech",
        isComingSoon: true,
        badgeIcon: _buildBadge(
          const Icon(Icons.volume_up_rounded, color: Color(0xFF238B45), size: 30),
        ),
      ),
      _FeatureCard(
        title: "Video Subtitle",
        description: "Translate videos and broadcasts into indigenous tribal languages with neural subtitling.",
        route: "/features/video-subtitle",
        badgeIcon: _buildBadge(
          Container(
            width: 38,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF238B45), width: 1.5),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF238B45), size: 18),
          ),
        ),
      ),
    ];
  }

  Widget _buildBadge(Widget inner) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EA),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD5E8D5)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner scanner accents
          Positioned(
            left: 10,
            top: 10,
            child: Container(width: 6, height: 6, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF238B45), width: 2), left: BorderSide(color: Color(0xFF238B45), width: 2)))),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Container(width: 6, height: 6, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF238B45), width: 2), right: BorderSide(color: Color(0xFF238B45), width: 2)))),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(width: 6, height: 6, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF238B45), width: 2), left: BorderSide(color: Color(0xFF238B45), width: 2)))),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(width: 6, height: 6, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF238B45), width: 2), right: BorderSide(color: Color(0xFF238B45), width: 2)))),
          ),
          Center(child: inner),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String route;
  final Widget badgeIcon;
  final bool isComingSoon;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.route,
    required this.badgeIcon,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E8D5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF238B45).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          badgeIcon,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17212B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667085),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                isComingSoon
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Coming Soon",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, route);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF238B45),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Start Translating",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 12),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
