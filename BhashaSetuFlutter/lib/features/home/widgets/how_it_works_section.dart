import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FBF7),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          // Top Floating Stickers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Sticker: "Simple Steps Real Change"
              Transform.rotate(
                angle: -0.1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD5E8D5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Simple Steps\nReal Change",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17212B),
                    ),
                  ),
                ),
              ),

              // Right Sticker: "From Voices to Opportunities"
              Transform.rotate(
                angle: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "From\nVoices to Opportunities",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF17212B),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 1.5,
                      margin: const EdgeInsets.only(top: 2),
                      color: const Color(0xFF238B45).withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header
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
                TextSpan(text: "How It "),
                TextSpan(
                  text: "Works",
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
            "Experience the simplicity of our contributor platform in just 3 easy steps.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 30),

          // 3 Step Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              final steps = [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ];

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((s) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: s))).toList(),
                );
              }
              return Column(
                children: steps.map((s) => Padding(padding: const EdgeInsets.only(bottom: 28), child: s)).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // Bottom Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1.5, color: const Color(0xFFD5E8D5)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Languages Connect People",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17212B),
                  ),
                ),
              ),
              Container(width: 40, height: 1.5, color: const Color(0xFFD5E8D5)),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 01: Choose Your Languages
  Widget _buildStep1() {
    return Column(
      children: [
        // Mockup Box
        Container(
          height: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD5E8D5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF238B45).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Floating Globe Disc
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5EA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD5E8D5)),
                  ),
                  child: const Icon(Icons.language_rounded, size: 16, color: Color(0xFF238B45)),
                ),
              ),

              // Inner Language Cards
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // English
                    Container(
                      width: 170,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF238B45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("English", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text("EN ▾", style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Swap Circle
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF238B45), width: 1.5),
                      ),
                      child: const Icon(Icons.swap_vert_rounded, size: 14, color: Color(0xFF238B45)),
                    ),
                    const SizedBox(height: 6),

                    // Santali
                    Container(
                      width: 170,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBF7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD5E8D5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Santali", style: TextStyle(color: Color(0xFF17212B), fontSize: 11, fontWeight: FontWeight.bold)),
                          Text("SNT ▾", style: TextStyle(color: Color(0xFF667085), fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Step Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD5E8D5)),
          ),
          child: const Text(
            "STEP 01",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF238B45), letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          "Choose Your Languages",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17212B)),
        ),
        const SizedBox(height: 4),

        const Text(
          "Select your source and target languages. We support translation to indigenous languages like Santali, Gondi, Bhili, and more.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF667085), height: 1.4),
        ),
      ],
    );
  }

  // STEP 02: Input Your Content
  Widget _buildStep2() {
    return Column(
      children: [
        // Mockup Box
        Container(
          height: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD5E8D5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF238B45).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFEAF5EA), borderRadius: BorderRadius.circular(6)),
                    child: const Text("Text", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF238B45))),
                  ),
                  const Text("Speech", style: TextStyle(fontSize: 9, color: Color(0xFF667085))),
                  const Text("Upload", style: TextStyle(fontSize: 9, color: Color(0xFF667085))),
                  const Text("Image", style: TextStyle(fontSize: 9, color: Color(0xFF667085))),
                ],
              ),

              // Placeholder Box with Mic
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBF7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD5E8D5)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Type, speak, or upload...",
                        style: TextStyle(fontSize: 10, color: Color(0xFF667085)),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(color: Color(0xFF238B45), shape: BoxShape.circle),
                      child: const Icon(Icons.mic_rounded, size: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Floating Mic with Waveform
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD5E8D5)),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 14, color: Color(0xFF238B45)),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: [
                      Container(width: 2, height: 8, color: const Color(0xFF238B45)),
                      const SizedBox(width: 2),
                      Container(width: 2, height: 14, color: const Color(0xFF238B45)),
                      const SizedBox(width: 2),
                      Container(width: 2, height: 6, color: const Color(0xFF238B45)),
                      const SizedBox(width: 2),
                      Container(width: 2, height: 12, color: const Color(0xFF238B45)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Step Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD5E8D5)),
          ),
          child: const Text(
            "STEP 02",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF238B45), letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          "Input Your Content",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17212B)),
        ),
        const SizedBox(height: 4),

        const Text(
          "Type text, speak, or upload images. Our AI platform handles multiple input formats for accessible and easy translation.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF667085), height: 1.4),
        ),
      ],
    );
  }

  // STEP 03: Get Instant Translation
  Widget _buildStep3() {
    return Column(
      children: [
        // Mockup Box
        Container(
          height: 170,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD5E8D5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF238B45).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Floating "✨ Translated" Badge
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD5E8D5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome_rounded, size: 10, color: Color(0xFF238B45)),
                      SizedBox(width: 3),
                      Text("Translated", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF238B45))),
                    ],
                  ),
                ),
              ),

              // Dark Green Gradient Card
              Center(
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF238B45), Color(0xFF176B3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("नमस्ते", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          Icon(Icons.volume_up_rounded, size: 14, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Hello", style: TextStyle(fontSize: 11, color: Colors.white)),
                          Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Icon(Icons.download_rounded, size: 12, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Step Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD5E8D5)),
          ),
          child: const Text(
            "STEP 03",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF238B45), letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          "Get Instant Translation",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF17212B)),
        ),
        const SizedBox(height: 4),

        const Text(
          "Receive translations instantly in real-time. Our advanced AI model ensures fast, accurate results for seamless communication.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Color(0xFF667085), height: 1.4),
        ),
      ],
    );
  }
}
