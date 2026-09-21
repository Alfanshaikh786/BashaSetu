import 'package:flutter/material.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';
import '../widgets/interactive_hero_phone.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF7),
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HERO SECTION ──
            _buildHeroSection(context),

            // ── FEATURES SECTION (6 Cards with Illustrated Badges) ──
            const FeaturesSection(),

            // ── HOW IT WORKS SECTION (3 Steps) ──
            const HowItWorksSection(),

            // ── FOOTER ──
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FBF7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 850;

          final textCol = Column(
            crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              // Headline
              RichText(
                textAlign: isWide ? TextAlign.left : TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17212B),
                    fontFamily: 'serif',
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(text: "Translate "),
                    TextSpan(
                      text: "Anything",
                      style: TextStyle(color: Color(0xFF238B45)),
                    ),
                    TextSpan(text: "\nInstantly with AI"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                "Type or speak. Get translation in your language instantly.",
                textAlign: isWide ? TextAlign.left : TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF667085),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // CTA Button: "Try Translation Now →"
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/features/text-to-text');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238B45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "Try Translation Now",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          );

          final phoneMockup = const Center(child: InteractiveHeroPhone());

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textCol),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: phoneMockup),
              ],
            );
          }

          return Column(
            children: [
              textCol,
              const SizedBox(height: 32),
              phoneMockup,
            ],
          );
        },
      ),
    );
  }
}
