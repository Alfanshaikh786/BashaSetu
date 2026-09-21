import 'package:flutter/material.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Content Card
                    _buildContentCard(),
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
        // Data Sovereignty Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD1EAD4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.shield_outlined, size: 14, color: Color(0xFF249144)),
              SizedBox(width: 6),
              Text(
                "Data Sovereignty & Protection",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14532D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          "Privacy Policy & Governance",
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
          "Ministry of Tribal Affairs guidelines for indigenous data sovereignty, user confidentiality, and open linguistic licensing.",
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

  Widget _buildContentCard() {
    return Container(
      padding: const EdgeInsets.all(32),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicySection(
            "1. Indigenous Linguistic Sovereignty",
            "All tribal folklore, audio samples, oral narratives, and manuscript scans submitted to the Bhasha Setu platform are governed by the Indigenous Data Sovereignty Framework. The intellectual and cultural rights remain with the respective tribal communities and custodial clans.",
          ),
          const SizedBox(height: 24),

          _buildPolicySection(
            "2. Processing of Text, Voice & OCR Data",
            "Queries entered in the Text-to-Text, Speech-to-Text, and OCR tools are processed in accordance with Digital Personal Data Protection (DPDP) Act standards. Data submitted for immediate translation is ephemerally evaluated and not monetized or transferred to third-party commercial entities.",
          ),
          const SizedBox(height: 24),

          _buildPolicySection(
            "3. Community Contributor Consent",
            "When linguists or community members contribute words, definitions, or audio chants, explicit consent is obtained to include these entries in the public Open Linguistic Knowledge Graph for academic and welfare enrichment.",
          ),
          const SizedBox(height: 24),

          _buildPolicySection(
            "4. Contact & Inquiries",
            "For grievances, data queries, or removal requests regarding cultural materials, contact our nodal data governance officer at:\n\nSahyadri College of Engineering and Management, Mangaluru\nEmail: alfanshaikh902@gmail.com",
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
