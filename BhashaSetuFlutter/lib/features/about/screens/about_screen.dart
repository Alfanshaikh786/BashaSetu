import 'package:flutter/material.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class LanguageCardData {
  final String name;
  final String speakers;
  final String history;
  final String importance;

  const LanguageCardData({
    required this.name,
    required this.speakers,
    required this.history,
    required this.importance,
  });
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const List<LanguageCardData> _preservedLanguages = [
    LanguageCardData(
      name: 'Santali',
      speakers: '7.6 million speakers',
      history: 'Santali is the mother tongue of the Santhal tribe and belongs to the Munda sub-family of Austroasiatic languages, written in the Ol Chiki script.',
      importance: "As one of India's 8th Schedule constitutional languages, Santali holds deep cultural, literary, social, and indigenous importance.",
    ),
    LanguageCardData(
      name: 'Mundari',
      speakers: '1.1+ million speakers',
      history: 'Mundari belongs to the Austro-Asiatic Munda language family and is spoken mainly across Jharkhand, Odisha, Chhattisgarh, and West Bengal.',
      importance: 'It is central to ancient tribal rituals, Sarhul festivals, folklore, sacred song traditions, and indigenous environmental knowledge systems.',
    ),
    LanguageCardData(
      name: 'Ho',
      speakers: '1.4+ million speakers',
      history: 'Ho is an Austroasiatic language of the Munda branch spoken predominantly in the Kolhan region of Jharkhand and Mayurbhanj in Odisha, traditionally written in the Warang Chiti script.',
      importance: 'It preserves the deep oral literature, sacred Jaher than grove rituals, Mage Porob and Baha festivals, and historical resistance lore of the Ho community.',
    ),
  ];

  static const List<Map<String, dynamic>> _impactAreas = [
    {
      'icon': Icons.public_rounded,
      'title': 'Governance Inclusion',
      'description': 'Translating official schemes and documents directly into tribal languages.',
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Healthcare Access',
      'description': 'Speech-to-speech and OCR tools for clear healthcare communication.',
    },
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Education',
      'description': 'Generating bilingual primers and digital learning resources.',
    },
    {
      'icon': Icons.mic_rounded,
      'title': 'Cultural Preservation',
      'description': 'Transcribing and translating oral traditions, songs, and stories.',
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Economic Empowerment',
      'description': 'Helping tribal communities participate fairly in markets and the digital economy.',
    },
  ];

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
                    // 1. Header Section
                    _buildHeader(),
                    const SizedBox(height: 48),

                    // 2. The Languages We Preserve
                    _buildLanguagesPreserved(),
                    const SizedBox(height: 48),

                    // 3. Our Impact Areas
                    _buildImpactAreas(),
                    const SizedBox(height: 48),

                    // 4. Tricolor Mission, Vision & Values
                    _buildTricolorSection(),
                    const SizedBox(height: 48),

                    // 5. Why Tribal Language Preservation Matters
                    _buildPreservationMattersBanner(),
                    const SizedBox(height: 48),

                    // 6. Our Commitment to Communities
                    _buildCommitmentCard(),
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

  // 1. Header Section
  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "About Bhasha Setu",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 12),

        // Underline bar with centered green accent
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160,
              height: 2,
              color: const Color(0xFFE2E8F0),
            ),
            Container(
              width: 70,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF249144),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        const Text(
          "India's first AI-powered platform dedicated to preserving and empowering tribal languages",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Dual Tagline Box
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B8C5A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B8C5A).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                "अपनी भाषा, अपनी विरासत, अपनी आवाज़",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our Language, Our Heritage, Our Voice",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF249144),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. The Languages We Preserve
  Widget _buildLanguagesPreserved() {
    return Column(
      children: [
        const Text(
          "The Languages We Preserve",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            final cards = _preservedLanguages.map((lang) {
              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF249144).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD1EAD4)),
                      ),
                      child: Text(
                        lang.speakers,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF249144),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      "HISTORY:",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lang.history,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "IMPORTANCE:",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lang.importance,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList(),
              );
            }
            return Column(
              children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
            );
          },
        ),
        const SizedBox(height: 16),

        // Summary Note Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Text(
            "Together, these languages represent India's linguistic diversity and the voices of millions who have been historically underrepresented.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Our Impact Areas
  Widget _buildImpactAreas() {
    return Column(
      children: [
        const Text(
          "Our Impact Areas",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            final cards = _impactAreas.map((area) {
              final IconData icon = area['icon'] as IconData;
              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: const Color(0xFF249144), size: 24),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      area['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      area['description'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();

            if (isWide) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 32) / 3, child: c)).toList(),
              );
            }
            return Column(
              children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: c)).toList(),
            );
          },
        ),
      ],
    );
  }

  // 4. Tricolor Mission, Vision & Values
  Widget _buildTricolorSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Colors.white, Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 750;
          final items = [
            _buildTricolorCard(
              title: "Our Mission",
              desc: "To bridge the digital divide for India's tribal communities through AI-powered translation technology.",
              icon: Icons.track_changes_rounded,
              bgColor: const Color(0xFFF0FDF9),
              borderColor: const Color(0xFFD1FAE5),
              iconBgColor: const Color(0xFF059669),
              textColor: const Color(0xFF065F46),
            ),
            _buildTricolorCard(
              title: "Our Vision",
              desc: "A digitally inclusive India where no citizen is left behind due to language barriers.",
              icon: Icons.people_rounded,
              bgColor: const Color(0xFFFFFBEB),
              borderColor: const Color(0xFFFEF3C7),
              iconBgColor: const Color(0xFFD97706),
              textColor: const Color(0xFF78350F),
            ),
            _buildTricolorCard(
              title: "Our Values",
              desc: "Respect, collaboration, authenticity, innovation, and empowerment through digital inclusion.",
              icon: Icons.military_tech_rounded,
              bgColor: const Color(0xFFFAF5FF),
              borderColor: const Color(0xFFF3E8FF),
              iconBgColor: const Color(0xFF7C3AED),
              textColor: const Color(0xFF581C87),
            ),
          ];

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
            );
          }
          return Column(
            children: items.map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: c)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTricolorCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color bgColor,
    required Color borderColor,
    required Color iconBgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Why Tribal Language Preservation Matters Banner
  Widget _buildPreservationMattersBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF3B8C5A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B8C5A).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: const [
          Text(
            "Why Tribal Language Preservation Matters",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 14),
          Text(
            "Tribal languages carry centuries of knowledge, traditions, songs, folklore, and cultural identity.\nBhasha Setu bridges the digital gap by preserving linguistic diversity while enabling practical empowerment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: Color(0xFFF0FDF4),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // 6. Our Commitment to Communities
  Widget _buildCommitmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handshake Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: const Icon(
              Icons.handshake_rounded,
              color: Color(0xFF249144),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "Our Commitment to Communities",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "We are committed to co-creating with tribal communities, ensuring authenticity, respect, and acceptance.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // 4 Green Pill Badges
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _CommitmentBadge(label: "Community-First Approach"),
              _CommitmentBadge(label: "Cultural Authenticity"),
              _CommitmentBadge(label: "Expert Validation"),
              _CommitmentBadge(label: "Inclusive Technology"),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommitmentBadge extends StatelessWidget {
  final String label;
  const _CommitmentBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCFCE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF065F46),
        ),
      ),
    );
  }
}
