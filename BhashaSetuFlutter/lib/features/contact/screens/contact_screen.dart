import 'package:flutter/material.dart';
import '../../../widgets/navigation/app_navbar.dart';
import '../../../widgets/navigation/app_drawer.dart';
import '../../../widgets/navigation/app_footer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _category = 'Feedback';
  String _language = 'Santali';
  bool _submitted = false;

  final List<Map<String, String>> _categories = [
    {'value': 'Feedback', 'label': 'Translation Quality Feedback'},
    {'value': 'Contributor', 'label': 'Linguist Contributor Enrollment'},
    {'value': 'Research', 'label': 'Academic Research Collaboration'},
    {'value': 'General', 'label': 'General Inquiry'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'Santali', 'label': 'Santali (ᱥᱟᱱᱛᱟᱲᱤ)'},
    {'value': 'Bhili', 'label': 'Bhili (भीली)'},
    {'value': 'Gondi', 'label': 'Gondi (गोंडी)'},
    {'value': 'Mundari', 'label': 'Mundari (ᱢᱩᱱᱰᱟᱨᱤ)'},
    {'value': 'Kui', 'label': 'Kui (କୁଇ)'},
    {'value': 'Garo', 'label': 'Garo (A·chik)'},
    {'value': 'Kokborok', 'label': 'Kokborok (ককবোরক)'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields."),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    setState(() => _submitted = true);
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
                    const SizedBox(height: 36),

                    // Two Column Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 850;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _buildLeftColumn()),
                              const SizedBox(width: 32),
                              Expanded(flex: 7, child: _buildRightColumn()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _buildLeftColumn(),
                            const SizedBox(height: 28),
                            _buildRightColumn(),
                          ],
                        );
                      },
                    ),
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
        // Community Engagement Pill
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
              Icon(Icons.mail_outline_rounded, size: 14, color: Color(0xFF249144)),
              SizedBox(width: 6),
              Text(
                "Community Engagement & Support",
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
          "Contact & Feedback",
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
          "Reach out to the Ministry of Tribal Affairs linguistic project team, submit translation feedback, or register as a language contributor.",
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

  Widget _buildLeftColumn() {
    return Column(
      children: [
        // Project Headquarters Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
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
              const Text(
                "Project Headquarters",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 18),

              // Address Item
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on_outlined, color: Color(0xFF249144), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "INSTITUTION / ADDRESS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "Sahyadri College of Engineering and Management, Mangaluru",
                          style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email Item
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF249144), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "OFFICIAL EMAIL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "alfanshaikh902@gmail.com",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF249144),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Native Linguists Wanted Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF14532D), Color(0xFF249144)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14532D).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Native Linguists Wanted",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'serif',
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Are you a native speaker or researcher of Santali, Bhili, Gondi, Kui, Garo, or Kokborok? Join our validation circle to test neural models.",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDCFCE7),
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _submitted ? _buildSuccessState() : _buildFormState(),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF86C498)),
          ),
          child: const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF249144)),
        ),
        const SizedBox(height: 18),
        const Text(
          "Message Dispatched Successfully!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Thank you for contributing to the Bhasha Setu ecosystem. Our linguistic research team will review your inquiry within 48 business hours.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _submitted = false;
              _nameController.clear();
              _emailController.clear();
              _messageController.clear();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF249144),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Send Another Message"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Email
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final nameField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Full Name", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "e.g. Dr. Rajesh Murmu",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5)),
                  ),
                ),
              ],
            );

            final emailField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Email Address", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "e.g. rajesh@university.ac.in",
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5)),
                  ),
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: nameField),
                  const SizedBox(width: 14),
                  Expanded(child: emailField),
                ],
              );
            }
            return Column(
              children: [
                nameField,
                const SizedBox(height: 14),
                emailField,
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Category & Primary Language
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final categoryField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Category", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5)),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ],
            );

            final languageField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Primary Tribal Language", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _language,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5)),
                  ),
                  items: _languages.map((l) => DropdownMenuItem(value: l['value'], child: Text(l['label']!))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _language = val);
                  },
                ),
              ],
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: categoryField),
                  const SizedBox(width: 14),
                  Expanded(child: languageField),
                ],
              );
            }
            return Column(
              children: [
                categoryField,
                const SizedBox(height: 14),
                languageField,
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        // Message
        const Text("Message / Suggestions", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _messageController,
          maxLines: 4,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: "Provide specific word suggestions, translation corrections, or collaboration details...",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF249144), width: 1.5)),
          ),
        ),
        const SizedBox(height: 20),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF249144),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.send_rounded, size: 16),
                SizedBox(width: 8),
                Text(
                  "Submit Inquiry to Ministry Team",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
